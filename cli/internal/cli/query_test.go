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
	f.lastOperation = operation
	f.lastArgs = args
}

func (f *fakeQueryService) SearchInstitutions(string) ([]Institution, error) { return nil, nil }
func (f *fakeQueryService) SearchNetworks(prefix string) ([]Network, error) {
	f.record("network search", prefix)
	return []Network{{Inst: 7, DlpsCIDRAddress: "192.0.2.0/24"}}, nil
}
func (f *fakeQueryService) InstitutionNetworks(inst string) ([]Network, error) {
	f.record("institution networks", inst)
	return []Network{{Inst: 7, DlpsCIDRAddress: "192.0.2.0/24"}}, nil
}
func (f *fakeQueryService) InstitutionGrants(inst string) ([]Access, error) {
	f.record("institution grants", inst)
	return []Access{{Coll: "example"}}, nil
}
func (f *fakeQueryService) UserShow(user string) (UserInspection, error) {
	f.record("user show", user)
	return UserInspection{UserID: user}, nil
}
func (f *fakeQueryService) ObjectsByPath(path string) ([]CollectionObject, error) {
	f.record("objects by-path", path)
	return []CollectionObject{{DlpsPath: path}}, nil
}
func (f *fakeQueryService) ObjectsByServer(server string) ([]CollectionObject, error) {
	f.record("objects by-server", server)
	return []CollectionObject{{DlpsServer: server}}, nil
}
func (f *fakeQueryService) CollectionShow(coll string) (CollectionInspection, error) {
	f.record("collection show", coll)
	return CollectionInspection{Collection: Collection{UniqueIdentifier: coll}}, nil
}
func (f *fakeQueryService) CollectionGrants(coll string) ([]Access, error) {
	f.record("collection grants", coll)
	return []Access{{Coll: coll}}, nil
}
func (f *fakeQueryService) AuthzDiagnostic(ip, user, coll string) (AuthzDiagnostic, error) {
	f.record("authzd_to_coll", ip, user, coll)
	return AuthzDiagnostic{Authorized: true}, nil
}

var _ = Describe("read-only query commands", func() {
	It("routes network search and returns the API response", func() {
		service := &fakeQueryService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "network", "search", "192.0.2"})

		Expect(command.Execute()).To(Succeed())
		Expect(service.lastOperation).To(Equal("network search"))
		Expect(service.lastArgs).To(Equal([]string{"192.0.2%"}))
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
		Entry("objects by path", []string{"objects", "by-path", "/books"}, "objects by-path", []string{"/books%"}),
		Entry("objects by server", []string{"objects", "by-server", "server"}, "objects by-server", []string{"server%"}),
		Entry("collection show", []string{"collection", "show", "example"}, "collection show", []string{"example%"}),
		Entry("collection grants", []string{"collection", "grants", "example"}, "collection grants", []string{"example%"}),
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

})
