package cli

import (
	"net/http"
	"net/http/httptest"
	"net/url"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("institution search API", func() {
	It("sends an authenticated REST request and decodes the response", func() {
		var request *http.Request
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			request = r
			w.Header().Set("Content-Type", "application/json")
			_, _ = w.Write([]byte(`{"institutions":[{"uniqueIdentifier":1,"organizationName":"Example University"}]}`))
		}))
		DeferCleanup(server.Close)

		client := NewAPIClient(server.URL, "test-key", server.Client())
		institutions, err := client.SearchInstitutions("Example")

		Expect(err).NotTo(HaveOccurred())
		Expect(request.Method).To(Equal(http.MethodGet))
		Expect(request.URL.Path).To(Equal("/institutions"))
		Expect(request.URL.Query()).To(Equal(url.Values{"organizationName": {"Example"}}))
		Expect(request.Header.Get("X-API-Key")).To(Equal("test-key"))
		Expect(institutions).To(ConsistOf(Institution{
			UniqueIdentifier: 1,
			OrganizationName: "Example University",
		}))
	})

	It("supports the remaining read-only query resources", func() {
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			switch r.URL.Path {
			case "/networks":
				Expect(r.URL.Query()).To(Equal(url.Values{"cidr": {"192.0.2%"}}))
				_, _ = w.Write([]byte(`{"networks":[{"inst":7,"dlpsCIDRAddress":"192.0.2.0/24"}]}`))
			case "/institutions/7/networks":
				_, _ = w.Write([]byte(`{"networks":[{"inst":7,"dlpsCIDRAddress":"192.0.2.0/24"}]}`))
			case "/institutions/7/collections":
				_, _ = w.Write([]byte(`{"collections":[{"coll":"example","inst":7}]}`))
			case "/users/alice":
				_, _ = w.Write([]byte(`{"userid":"alice","memberships":[],"collections":[]}`))
			case "/objects":
				if r.URL.Query().Get("path") != "" {
					Expect(r.URL.Query()).To(Equal(url.Values{"path": {"/books%"}}))
				} else {
					Expect(r.URL.Query()).To(Equal(url.Values{"server": {"server%"}}))
				}
				_, _ = w.Write([]byte(`{"objects":[{"dlpsServer":"server.example","dlpsPath":"/books/example"}]}`))
			case "/collections/example":
				_, _ = w.Write([]byte(`{"collection":{"uniqueIdentifier":"example"},"access":[]}`))
			case "/collections/example/access":
				_, _ = w.Write([]byte(`{"access":[{"coll":"example","inst":7}]}`))
			case "/authzd_to_coll":
				Expect(r.URL.Query()).To(Equal(url.Values{
					"ip":         {"192.0.2.1"},
					"userid":     {"alice"},
					"collection": {"example"},
				}))
				_, _ = w.Write([]byte(`{"authorized":true}`))
			default:
				Fail("unexpected API path: " + r.URL.Path)
			}
		}))
		DeferCleanup(server.Close)

		client := NewAPIClient(server.URL, "test-key", server.Client())
		networks, err := client.SearchNetworks("192.0.2%")
		Expect(err).NotTo(HaveOccurred())
		Expect(networks).To(HaveLen(1))

		networks, err = client.InstitutionNetworks("7")
		Expect(err).NotTo(HaveOccurred())
		Expect(networks[0].Inst).To(Equal(7))

		collections, err := client.InstitutionGrants("7")
		Expect(err).NotTo(HaveOccurred())
		Expect(collections[0].Coll).To(Equal("example"))

		user, err := client.UserShow("alice")
		Expect(err).NotTo(HaveOccurred())
		Expect(user.UserID).To(Equal("alice"))

		objects, err := client.ObjectsByPath("/books%")
		Expect(err).NotTo(HaveOccurred())
		Expect(objects[0].DlpsPath).To(Equal("/books/example"))

		objects, err = client.ObjectsByServer("server%")
		Expect(err).NotTo(HaveOccurred())
		Expect(objects[0].DlpsServer).To(Equal("server.example"))

		collection, err := client.CollectionShow("example")
		Expect(err).NotTo(HaveOccurred())
		Expect(collection.Collection.UniqueIdentifier).To(Equal("example"))

		access, err := client.CollectionGrants("example")
		Expect(err).NotTo(HaveOccurred())
		Expect(access[0].Coll).To(Equal("example"))

		diagnostic, err := client.AuthzDiagnostic("192.0.2.1", "alice", "example")
		Expect(err).NotTo(HaveOccurred())
		Expect(diagnostic.Authorized).To(BeTrue())
	})

	It("fetches an authorization export", func() {
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			Expect(r.URL.Path).To(Equal("/export"))
			w.Header().Set("Content-Type", "application/json")
			_, _ = w.Write([]byte(`{"institutions":[{"uniqueIdentifier":1}],"grants":[{"coll":"example"}]}`))
		}))
		DeferCleanup(server.Close)

		client := NewAPIClient(server.URL, "test-key", server.Client())
		export, err := client.Export()

		Expect(err).NotTo(HaveOccurred())
		Expect(export).To(HaveKeyWithValue("institutions", []any{map[string]any{"uniqueIdentifier": float64(1)}}))
		Expect(export).To(HaveKey("grants"))
	})

	It("fetches replication status", func() {
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			Expect(r.URL.Path).To(Equal("/replication/status"))
			w.Header().Set("Content-Type", "application/json")
			_, _ = w.Write([]byte(`{"status":"healthy","stale":false}`))
		}))
		DeferCleanup(server.Close)

		client := NewAPIClient(server.URL, "test-key", server.Client())
		status, err := client.ReplicationStatus()

		Expect(err).NotTo(HaveOccurred())
		Expect(status).To(HaveKeyWithValue("status", "healthy"))
		Expect(status).To(HaveKeyWithValue("stale", false))
	})
})
