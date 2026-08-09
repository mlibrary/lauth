package cli

import (
	"bytes"
	"encoding/json"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

type fakeQueryService struct {
	lastOperation string
	lastArgs      []string
}

func (f *fakeQueryService) record(operation string, args ...string) {
	f.lastOperation, f.lastArgs = operation, args
}
func (f *fakeQueryService) SearchInstitutions(string) ([]Institution, error) { return nil, nil }
func (f *fakeQueryService) SearchNetworks(search NetworkSearch) ([]Network, error) {
	f.record("network search", search.IP, search.Prefix, search.CIDR, search.RangeStart, search.RangeEnd)
	return []Network{{Inst: 7, DlpsCIDRAddress: "192.0.2.0/24"}}, nil
}
func (f *fakeQueryService) InstitutionNetworks(inst string) ([]Network, error) {
	f.record("institution networks", inst)
	return []Network{{Inst: 7}}, nil
}
func (f *fakeQueryService) InstitutionGrants(inst string) ([]Grant, error) {
	f.record("institution grants", inst)
	return []Grant{{Coll: "example"}}, nil
}
func (f *fakeQueryService) UserShow(user string) (UserInspection, error) {
	f.record("user show", user)
	return UserInspection{UserID: user}, nil
}
func (f *fakeQueryService) SearchLocations(path, server string) ([]Location, error) {
	f.record("locations search", path, server)
	return []Location{{DlpsPath: path, DlpsServer: server}}, nil
}
func (f *fakeQueryService) CollectionSearch(pattern string) ([]Collection, error) {
	f.record("collection search", pattern)
	return []Collection{{UniqueIdentifier: pattern}}, nil
}
func (f *fakeQueryService) CollectionShow(coll string) (CollectionInspection, error) {
	f.record("collection show", coll)
	return CollectionInspection{Collection: Collection{UniqueIdentifier: coll}}, nil
}
func (f *fakeQueryService) CollectionGrants(coll string) ([]Grant, error) {
	f.record("collection grants", coll)
	return []Grant{{Coll: coll}}, nil
}
func (f *fakeQueryService) AuthzDiagnostic(ip, user, coll string) (AuthzDiagnostic, error) {
	f.record("authzd_to_coll", ip, user, coll)
	return AuthzDiagnostic{Authorized: true}, nil
}

var _ = Describe("read-only query commands", func() {
	It("routes network search flags and returns the API response", func() {
		service := &fakeQueryService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "network", "search", "--prefix", "192.0.2"})

		Expect(command.Execute()).To(Succeed())
		Expect(service.lastOperation).To(Equal("network search"))
		Expect(service.lastArgs).To(Equal([]string{"", "192.0.2", "", "", ""}))
		Expect(output.String()).To(ContainSubstring(`"dlpsCIDRAddress":"192.0.2.0/24"`))
	})

	DescribeTable("routes query commands",
		func(args []string, operation string, expectedArgs []string) {
			service := &fakeQueryService{}
			var output bytes.Buffer
			command := NewRootCommand(service, &output)
			command.SetArgs(append([]string{"--output=json"}, args...))
			Expect(command.Execute()).To(Succeed())
			Expect(service.lastOperation).To(Equal(operation))
			Expect(service.lastArgs).To(Equal(expectedArgs))
		},
		Entry("institution networks", []string{"institution", "networks", "7"}, "institution networks", []string{"7"}),
		Entry("institution grants", []string{"institution", "grants", "7"}, "institution grants", []string{"7"}),
		Entry("user show", []string{"user", "show", "alice"}, "user show", []string{"alice"}),
		Entry("locations search", []string{"locations", "search", "--path", "/books", "--server", "server.example"}, "locations search", []string{"/books", "server.example"}),
		Entry("collection search", []string{"collection", "search", "example*"}, "collection search", []string{"example*"}),
		Entry("collection show", []string{"collection", "show", "example"}, "collection show", []string{"example"}),
		Entry("collection grants", []string{"collection", "grants", "example"}, "collection grants", []string{"example"}),
		Entry("authorization diagnostic", []string{"authzd_to_coll", "192.0.2.1", "alice", "example"}, "authzd_to_coll", []string{"192.0.2.1", "alice", "example"}),
	)

	It("returns structured JSON for user inspection", func() {
		service := &fakeQueryService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "user", "show", "alice"})
		Expect(command.Execute()).To(Succeed())
		var response UserInspection
		Expect(json.Unmarshal(output.Bytes(), &response)).To(Succeed())
		Expect(response.UserID).To(Equal("alice"))
	})

	It("rejects a location search without filters", func() {
		command := NewRootCommand(&fakeQueryService{}, &bytes.Buffer{})
		command.SetArgs([]string{"locations", "search"})
		Expect(command.Execute()).To(MatchError("at least one of --path or --server is required"))
	})

	It("rejects combined or incomplete network modes", func() {
		for _, args := range [][]string{
			{"network", "search"},
			{"network", "search", "--ip", "192.0.2.1", "--cidr", "192.0.2.0/24"},
			{"network", "search", "--range-start", "192.0.2.1"},
		} {
			command := NewRootCommand(&fakeQueryService{}, &bytes.Buffer{})
			command.SetArgs(args)
			Expect(command.Execute()).To(MatchError("exactly one complete network search mode is required"))
		}
	})
})
