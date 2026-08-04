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
})
