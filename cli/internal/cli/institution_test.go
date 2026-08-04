package cli

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("institution search", func() {
	It("lists institutions returned by the API as a table by default", func() {
		searcher := &fakeInstitutionSearcher{institutions: []Institution{{
			UniqueIdentifier: 1,
			OrganizationName: "Example University",
		}}}
		var output bytes.Buffer
		command := NewRootCommand(searcher, &output)
		command.SetArgs([]string{"institution", "search", "Example", "University"})

		Expect(command.Execute()).To(Succeed())
		Expect(searcher.pattern).To(Equal("Example%University"))
		Expect(output.String()).To(Equal("UNIQUEIDENTIFIER  ORGANIZATIONNAME\n1                 Example University\n"))
	})

	It("lists institutions as JSON when requested", func() {
		searcher := &fakeInstitutionSearcher{institutions: []Institution{{
			UniqueIdentifier: 1,
			OrganizationName: "Example University",
		}}}
		var output bytes.Buffer
		command := NewRootCommand(searcher, &output)
		command.SetArgs([]string{"--output=json", "institution", "search", "Example"})

		Expect(command.Execute()).To(Succeed())

		var response map[string][]Institution
		Expect(json.Unmarshal(output.Bytes(), &response)).To(Succeed())
		Expect(response["institutions"]).To(ConsistOf(Institution{
			UniqueIdentifier: 1,
			OrganizationName: "Example University",
		}))
	})

	It("lists institutions using database schema attribute names", func() {
		response, err := os.ReadFile(filepath.Join("..", "..", "testdata", "institution_search_response.json"))
		Expect(err).NotTo(HaveOccurred())

		institutions, err := parseInstitutionSearchResponse(response)
		Expect(err).NotTo(HaveOccurred())
		Expect(institutions).To(HaveLen(2))
		Expect(institutions[0].UniqueIdentifier).To(Equal(1))
		Expect(institutions[0].OrganizationName).To(Equal("Example University"))
	})
})

func TestInstitutionSearch(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Institution Search Suite")
}
