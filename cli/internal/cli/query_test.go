package cli

import (
	"bytes"
	"encoding/json"
	"errors"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

type fakeQueryService struct {
	lastOperation string
	lastArgs      []string
	empty         bool
	queryErr      error
}

func (f *fakeQueryService) record(operation string, args ...string) {
	f.lastOperation, f.lastArgs = operation, args
}
func (f *fakeQueryService) SearchInstitutions(string) ([]Institution, error) { return nil, nil }
func (f *fakeQueryService) SearchNetworks(search NetworkSearch) ([]Network, error) {
	f.record("network search", search.IP, search.Prefix, search.CIDR, search.RangeStart, search.RangeEnd)
	if f.queryErr != nil {
		return nil, f.queryErr
	}
	if f.empty {
		return []Network{}, nil
	}
	return []Network{{Inst: 7, DlpsCIDRAddress: "192.0.2.0/24"}}, nil
}
func (f *fakeQueryService) InstitutionNetworks(inst string) ([]Network, error) {
	f.record("institution networks", inst)
	if f.queryErr != nil {
		return nil, f.queryErr
	}
	if f.empty {
		return []Network{}, nil
	}
	return []Network{{Inst: 7}}, nil
}
func (f *fakeQueryService) InstitutionGrants(inst string) ([]Grant, error) {
	f.record("institution grants", inst)
	if f.queryErr != nil {
		return nil, f.queryErr
	}
	if f.empty {
		return []Grant{}, nil
	}
	return []Grant{{Coll: "example"}}, nil
}
func (f *fakeQueryService) UserShow(user string) (UserInspection, error) {
	f.record("user show", user)
	if f.queryErr != nil {
		return UserInspection{}, f.queryErr
	}
	return UserInspection{
		UserID: user,
		User: map[string]any{
			"userid":      "alice",
			"givenName":   "Alice",
			"dlpsDeleted": "f",
		},
		Memberships: []map[string]any{{"userid": user, "inst": 7, "dlpsDeleted": "f"}},
		Grants:      []Grant{{UniqueIdentifier: 11, UserID: user, Inst: 7, Coll: "example"}},
	}, nil
}
func (f *fakeQueryService) SearchLocations(path, server string) ([]Location, error) {
	f.record("location search", path, server)
	if f.queryErr != nil {
		return nil, f.queryErr
	}
	if f.empty {
		return []Location{}, nil
	}
	return []Location{{DlpsPath: path, DlpsServer: server}}, nil
}
func (f *fakeQueryService) CollectionSearch(pattern string) ([]Collection, error) {
	f.record("collection search", pattern)
	if f.queryErr != nil {
		return nil, f.queryErr
	}
	if f.empty {
		return []Collection{}, nil
	}
	return []Collection{{UniqueIdentifier: pattern}}, nil
}
func (f *fakeQueryService) CollectionShow(coll string) (CollectionInspection, error) {
	f.record("collection show", coll)
	if f.queryErr != nil {
		return CollectionInspection{}, f.queryErr
	}
	return CollectionInspection{
		Collection: Collection{
			UniqueIdentifier: coll,
			CommonName:       "Example",
			Description:      "Example collection",
			DlpsClass:        "example-class",
			DlpsAuthzType:    "n",
		},
		Grants: []Grant{{UniqueIdentifier: 12, Inst: 7, Coll: coll}},
	}, nil
}
func (f *fakeQueryService) CollectionGrants(coll string) ([]Grant, error) {
	f.record("collection grants", coll)
	if f.queryErr != nil {
		return nil, f.queryErr
	}
	if f.empty {
		return []Grant{}, nil
	}
	return []Grant{{Coll: coll}}, nil
}
func (f *fakeQueryService) CheckAccess(user, coll, ip string) (AccessResult, error) {
	f.record("access check", user, coll, ip)
	return AccessResult{Determination: "allowed"}, nil
}

var _ = Describe("read-only query commands", func() {
	It("renders the active legacy script mappings without invoking a service", func() {
		var output bytes.Buffer
		command := NewRootCommand(&fakeQueryService{}, &output)
		command.SetArgs([]string{"legacy-scripts"})

		Expect(command.Execute()).To(Succeed())
		Expect(output.String()).To(ContainSubstring("qi               institution search"))
		Expect(output.String()).To(ContainSubstring("authzd_to_coll   access check"))
		Expect(output.String()).To(ContainSubstring("location search"))
		Expect(output.String()).NotTo(ContainSubstring("aggis"))
		Expect(output.String()).NotTo(ContainSubstring("vip"))
	})

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
		Entry("location search", []string{"location", "search", "--path", "/books", "--server", "server.example"}, "location search", []string{"/books", "server.example"}),
		Entry("collection search", []string{"collection", "search", "example*"}, "collection search", []string{"example*"}),
		Entry("collection show", []string{"collection", "show", "example"}, "collection show", []string{"example"}),
		Entry("collection grants", []string{"collection", "grants", "example"}, "collection grants", []string{"example"}),
		Entry("access check", []string{"access", "check", "alice", "example", "192.0.2.1"}, "access check", []string{"alice", "example", "192.0.2.1"}),
		Entry("access check without IP", []string{"access", "check", "alice", "example"}, "access check", []string{"alice", "example", ""}),
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

	It("returns structured JSON for collection inspection", func() {
		service := &fakeQueryService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "collection", "show", "example"})

		Expect(command.Execute()).To(Succeed())
		var response CollectionInspection
		Expect(json.Unmarshal(output.Bytes(), &response)).To(Succeed())
		Expect(response.Collection.UniqueIdentifier).To(Equal("example"))
	})

	DescribeTable("returns an empty JSON envelope", func(args []string, expected string) {
		service := &fakeQueryService{empty: true}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs(append([]string{"--output=json"}, args...))

		Expect(command.Execute()).To(Succeed())
		Expect(output.String()).To(Equal(expected + "\n"))
	},
		Entry("network search", []string{"network", "search", "--ip", "192.0.2.1"}, `{"networks":[]}`),
		Entry("institution networks", []string{"institution", "networks", "7"}, `{"networks":[]}`),
		Entry("institution grants", []string{"institution", "grants", "7"}, `{"grants":[]}`),
		Entry("location search", []string{"location", "search", "--path", "/books"}, `{"locations":[]}`),
		Entry("collection search", []string{"collection", "search", "example"}, `{"collections":[]}`),
		Entry("collection grants", []string{"collection", "grants", "example"}, `{"grants":[]}`),
	)

	DescribeTable("propagates service errors at the command boundary", func(args []string) {
		service := &fakeQueryService{queryErr: errors.New("api unavailable")}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs(args)

		Expect(command.Execute()).To(MatchError("api unavailable"))
		Expect(output.String()).To(BeEmpty())
	},
		Entry("network search", []string{"network", "search", "--ip", "192.0.2.1"}),
		Entry("institution networks", []string{"institution", "networks", "7"}),
		Entry("institution grants", []string{"institution", "grants", "7"}),
		Entry("location search", []string{"location", "search", "--path", "/books"}),
		Entry("collection search", []string{"collection", "search", "example"}),
		Entry("collection show", []string{"collection", "show", "example"}),
		Entry("collection grants", []string{"collection", "grants", "example"}),
		Entry("user show", []string{"user", "show", "alice"}),
	)

	DescribeTable("renders active query results as tables by default", func(args []string, expected []string) {
		var output bytes.Buffer
		command := NewRootCommand(&fakeQueryService{}, &output)
		command.SetArgs(args)

		Expect(command.Execute()).To(Succeed())
		for _, value := range expected {
			Expect(output.String()).To(ContainSubstring(value))
		}
	},
		Entry("network search", []string{"network", "search", "--ip", "192.0.2.1"}, []string{"INST", "DLPSCIDRADDRESS", "192.0.2.0/24"}),
		Entry("institution networks", []string{"institution", "networks", "7"}, []string{"INST", "DLPSCIDRADDRESS", "7"}),
		Entry("institution grants", []string{"institution", "grants", "7"}, []string{"COLL", "LASTMODIFIEDTIME", "example"}),
		Entry("location search", []string{"location", "search", "--path", "/books"}, []string{"DLPSPATH", "DLPSSERVER", "/books"}),
		Entry("collection search", []string{"collection", "search", "example"}, []string{"UNIQUEIDENTIFIER", "example"}),
		Entry("collection show", []string{"collection", "show", "example"}, []string{"UNIQUEIDENTIFIER", "COMMONNAME", "DESCRIPTION", "example"}),
		Entry("collection grants", []string{"collection", "grants", "example"}, []string{"COLL", "LASTMODIFIEDTIME", "example"}),
		Entry("user show", []string{"user", "show", "alice"}, []string{"USERID", "alice"}),
	)

	It("includes nested user and collection inspection data in table output", func() {
		userOutput := new(bytes.Buffer)
		userCommand := NewRootCommand(&fakeQueryService{}, userOutput)
		userCommand.SetArgs([]string{"user", "show", "alice"})
		Expect(userCommand.Execute()).To(Succeed())
		Expect(userOutput.String()).To(And(
			ContainSubstring("GIVENNAME"),
			ContainSubstring("Alice"),
			ContainSubstring("MEMBERSHIPS"),
			ContainSubstring("7"),
			ContainSubstring("GRANTS"),
			ContainSubstring("example"),
		))

		collectionOutput := new(bytes.Buffer)
		collectionCommand := NewRootCommand(&fakeQueryService{}, collectionOutput)
		collectionCommand.SetArgs([]string{"collection", "show", "example"})
		Expect(collectionCommand.Execute()).To(Succeed())
		Expect(collectionOutput.String()).To(And(
			ContainSubstring("DLPSCLASS"),
			ContainSubstring("example-class"),
			ContainSubstring("GRANTS"),
			ContainSubstring("example"),
		))
	})

	It("rejects unsupported output formats", func() {
		service := &fakeQueryService{}
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetArgs([]string{"--output=csv", "collection", "search", "example"})

		Expect(command.Execute()).To(MatchError(`unsupported output format "csv"`))
	})

	DescribeTable("rejects missing or extra query arguments", func(args []string) {
		command := NewRootCommand(&fakeQueryService{}, &bytes.Buffer{})
		command.SetArgs(args)

		Expect(command.Execute()).NotTo(Succeed())
	},
		Entry("missing user", []string{"user", "show"}),
		Entry("extra user", []string{"user", "show", "alice", "extra"}),
		Entry("missing collection", []string{"collection", "show"}),
		Entry("extra collection", []string{"collection", "show", "example", "extra"}),
		Entry("missing institution", []string{"institution", "networks"}),
		Entry("extra institution", []string{"institution", "networks", "7", "extra"}),
	)

	It("rejects a location search without filters", func() {
		command := NewRootCommand(&fakeQueryService{}, &bytes.Buffer{})
		command.SetArgs([]string{"location", "search"})
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
