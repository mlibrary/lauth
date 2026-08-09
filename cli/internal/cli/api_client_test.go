package cli

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("administrative API", func() {
	It("sends an authenticated versioned REST request and decodes the response", func() {
		var request *http.Request
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			request = r
			w.Header().Set("Content-Type", "application/json")
			_, _ = w.Write([]byte(`{"institutions":[{"uniqueIdentifier":1,"organizationName":"Example University"}]}`))
		}))
		DeferCleanup(server.Close)

		client := NewAPIClient(server.URL, "test-token", server.Client())
		institutions, err := client.SearchInstitutions("Example")

		Expect(err).NotTo(HaveOccurred())
		Expect(request.Method).To(Equal(http.MethodGet))
		Expect(request.URL.Path).To(Equal("/api/v1/institutions"))
		Expect(request.URL.Query()).To(Equal(url.Values{"organizationName": {"Example"}}))
		Expect(request.Header.Get("Authorization")).To(Equal("Bearer test-token"))
		Expect(institutions).To(ConsistOf(Institution{UniqueIdentifier: 1, OrganizationName: "Example University"}))
	})

	It("uses the finalized active resource paths and envelopes", func() {
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			switch r.URL.Path {
			case "/api/v1/networks":
				Expect(r.URL.Query()).To(Equal(url.Values{"prefix": {"192.0.2"}}))
				_, _ = w.Write([]byte(`{"networks":[{"inst":7,"dlpsCIDRAddress":"192.0.2.0/24"}]}`))
			case "/api/v1/institutions/7/networks":
				if r.Method == http.MethodGet {
					_, _ = w.Write([]byte(`{"networks":[{"inst":7,"dlpsCIDRAddress":"192.0.2.0/24"}]}`))
					break
				}
				Expect(r.Method).To(Equal(http.MethodPost))
				var body struct {
					CIDRs        []string `json:"cidrs"`
					AccessSwitch string   `json:"accessSwitch"`
				}
				Expect(json.NewDecoder(r.Body).Decode(&body)).To(Succeed())
				Expect(body.CIDRs).To(Equal([]string{"192.0.2.0/24", "198.51.100.0/25"}))
				Expect(body.AccessSwitch).To(Equal("allow"))
				w.WriteHeader(http.StatusCreated)
				_, _ = w.Write([]byte(`{"networks":[{"inst":7,"dlpsCIDRAddress":"192.0.2.0/24"},{"inst":7,"dlpsCIDRAddress":"198.51.100.0/25"}]}`))
			case "/api/v1/institutions/7/grants":
				_, _ = w.Write([]byte(`{"grants":[{"coll":"example","inst":7}]}`))
			case "/api/v1/users/alice":
				_, _ = w.Write([]byte(`{"userid":"alice","memberships":[],"grants":[]}`))
			case "/api/v1/locations":
				Expect(r.URL.Query()).To(Equal(url.Values{"path": {"/books"}, "server": {"server.example"}}))
				_, _ = w.Write([]byte(`{"locations":[{"dlpsServer":"server.example","dlpsPath":"/books/example"}]}`))
			case "/api/v1/collections":
				_, _ = w.Write([]byte(`{"collections":[{"uniqueIdentifier":"example"}]}`))
			case "/api/v1/collections/example":
				_, _ = w.Write([]byte(`{"collection":{"uniqueIdentifier":"example"},"grants":[]}`))
			case "/api/v1/collections/example/grants":
				_, _ = w.Write([]byte(`{"grants":[{"coll":"example","inst":7}]}`))
			case "/api/v1/institutions":
				Expect(r.Method).To(Equal(http.MethodPost))
				Expect(r.Header.Get("Content-Type")).To(Equal("application/json"))
				var body map[string]string
				Expect(json.NewDecoder(r.Body).Decode(&body)).To(Succeed())
				Expect(body).To(Equal(map[string]string{"organizationName": "Example University"}))
				w.WriteHeader(http.StatusCreated)
				_, _ = w.Write([]byte(`{"institution":{"uniqueIdentifier":8,"organizationName":"Example University"}}`))
			case "/authzd_to_coll":
				_, _ = w.Write([]byte(`{"authorized":true}`))
			default:
				Fail("unexpected API path: " + r.URL.Path)
			}
		}))
		DeferCleanup(server.Close)

		client := NewAPIClient(server.URL, "test-token", server.Client())
		networks, err := client.SearchNetworks(NetworkSearch{Prefix: "192.0.2"})
		Expect(err).NotTo(HaveOccurred())
		Expect(networks).To(HaveLen(1))
		_, err = client.InstitutionNetworks("7")
		Expect(err).NotTo(HaveOccurred())
		grants, err := client.InstitutionGrants("7")
		Expect(err).NotTo(HaveOccurred())
		Expect(grants[0].Coll).To(Equal("example"))
		_, err = client.UserShow("alice")
		Expect(err).NotTo(HaveOccurred())
		locations, err := client.SearchLocations("/books", "server.example")
		Expect(err).NotTo(HaveOccurred())
		Expect(locations[0].DlpsPath).To(Equal("/books/example"))
		collections, err := client.CollectionSearch("example*")
		Expect(err).NotTo(HaveOccurred())
		Expect(collections[0].UniqueIdentifier).To(Equal("example"))
		collection, err := client.CollectionShow("example")
		Expect(err).NotTo(HaveOccurred())
		Expect(collection.Collection.UniqueIdentifier).To(Equal("example"))
		grants, err = client.CollectionGrants("example")
		Expect(err).NotTo(HaveOccurred())
		Expect(grants[0].Coll).To(Equal("example"))
		institution, err := client.CreateInstitution("Example University")
		Expect(err).NotTo(HaveOccurred())
		Expect(institution.UniqueIdentifier).To(Equal(8))
		networks, err = client.CreateNetworks("7", []string{"192.0.2.0/24", "198.51.100.0/25"}, "allow")
		Expect(err).NotTo(HaveOccurred())
		Expect(networks).To(HaveLen(2))
	})

	It("normalizes structured API errors", func() {
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			w.WriteHeader(http.StatusBadRequest)
			_, _ = w.Write([]byte(`{"error":{"code":"invalid_parameter","message":"bad input"}}`))
		}))
		DeferCleanup(server.Close)

		_, err := NewAPIClient(server.URL, "test-token", server.Client()).SearchInstitutions("bad")
		Expect(err).To(MatchError("invalid_parameter: bad input"))
	})

	It("propagates structured errors from mutation endpoints", func() {
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnprocessableEntity)
			if r.URL.Path == "/api/v1/institutions" {
				_, _ = w.Write([]byte(`{"error":{"code":"duplicate_institution","message":"already exists"}}`))
				return
			}
			_, _ = w.Write([]byte(`{"error":{"code":"invalid_network","message":"network rejected"}}`))
		}))
		DeferCleanup(server.Close)

		client := NewAPIClient(server.URL, "test-token", server.Client())
		_, err := client.CreateInstitution("Example University")
		Expect(err).To(MatchError("duplicate_institution: already exists"))
		_, err = client.CreateNetworks("7", []string{"192.0.2.0/24"}, "allow")
		Expect(err).To(MatchError("invalid_network: network rejected"))
	})

	It("requires the active API base URL and token", func() {
		_, err := NewAPIClient("", "test-token", nil).SearchInstitutions("Example")
		Expect(err).To(MatchError("AUTHZ_API_BASE_URL is required"))

		_, err = NewAPIClient("http://api.example", "", nil).SearchInstitutions("Example")
		Expect(err).To(MatchError("AUTHZ_API_TOKEN is required"))
	})
})
