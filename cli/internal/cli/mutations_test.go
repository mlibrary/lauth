package cli

import (
	"bytes"
	"encoding/json"
	"errors"
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

type fakeMutationService struct {
	fakeQueryService
	createdInstitution string
	institutionCalls   int
	institutionID      string
	cidrs              []string
	accessSwitch       string
	institutionErr     error
	networkErr         error
	networks           []Network
}

func (f *fakeMutationService) CreateInstitution(name string) (Institution, error) {
	f.institutionCalls++
	f.createdInstitution = name
	if f.institutionErr != nil {
		return Institution{}, f.institutionErr
	}
	return Institution{UniqueIdentifier: 8, OrganizationName: name}, nil
}

func (f *fakeMutationService) CreateNetworks(institutionID string, cidrs []string, accessSwitch string) ([]Network, error) {
	f.institutionID = institutionID
	f.cidrs = cidrs
	f.accessSwitch = accessSwitch
	if f.networkErr != nil {
		return nil, f.networkErr
	}
	if f.networks != nil {
		return f.networks, nil
	}
	if len(cidrs) == 0 {
		return []Network{}, nil
	}
	return []Network{{Inst: 8, DlpsCIDRAddress: cidrs[0], DlpsAccessSwitch: accessSwitch}}, nil
}

var _ = Describe("mutation commands", func() {
	It("rejects a missing institution name before calling the service", func() {
		service := &fakeMutationService{}
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetArgs([]string{"institution", "add"})

		Expect(command.Execute()).To(MatchError("accepts 1 arg(s), received 0"))
		Expect(service.institutionCalls).To(Equal(0))
	})

	It("rejects an empty or whitespace institution name before calling the service", func() {
		for _, name := range []string{"", "   \t"} {
			service := &fakeMutationService{}
			command := NewRootCommand(service, &bytes.Buffer{})
			command.SetArgs([]string{"institution", "add", name})

			Expect(command.Execute()).To(MatchError("organization name cannot be empty"))
			Expect(service.institutionCalls).To(Equal(0))
		}
	})

	It("creates an institution through the inst alias", func() {
		service := &fakeMutationService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "inst", "add", "Example University"})

		Expect(command.Execute()).To(Succeed())
		Expect(service.createdInstitution).To(Equal("Example University"))
		Expect(output.String()).To(ContainSubstring(`"organizationName":"Example University"`))
	})

	It("uses the table format by default for institution creation", func() {
		service := &fakeMutationService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"institution", "add", "Example University"})

		Expect(command.Execute()).To(Succeed())
		Expect(output.String()).To(Equal("UNIQUEIDENTIFIER  ORGANIZATIONNAME\n8                 Example University\n"))
	})

	It("renders the exact institution JSON envelope", func() {
		service := &fakeMutationService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "institution", "add", "Example University"})

		Expect(command.Execute()).To(Succeed())
		Expect(output.String()).To(Equal("{\"institutions\":[{\"uniqueIdentifier\":8,\"organizationName\":\"Example University\"}]}\n"))
	})

	It("uses the shared output contract for mutation results", func() {
		var output bytes.Buffer
		command := NewRootCommand(&fakeMutationService{}, &output)
		command.SetArgs([]string{"--output=json", "institution", "add", "Example University"})

		Expect(command.Execute()).To(Succeed())
		Expect(output.String()).To(Equal("{\"institutions\":[{\"uniqueIdentifier\":8,\"organizationName\":\"Example University\"}]}\n"))
	})

	It("propagates institution mutation errors without output", func() {
		service := &fakeMutationService{institutionErr: errors.New("invalid_parameter: duplicate institution")}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"institution", "add", "Example University"})

		Expect(command.Execute()).To(MatchError("invalid_parameter: duplicate institution"))
		Expect(output.String()).To(BeEmpty())
	})

	It("posts an already canonical CIDR immediately through the net alias", func() {
		service := &fakeMutationService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "net", "add", "-i", "7", "-c", "192.0.2.0/24"})

		Expect(command.Execute()).To(Succeed())
		Expect(service.institutionID).To(Equal("7"))
		Expect(service.cidrs).To(Equal([]string{"192.0.2.0/24"}))
		Expect(service.accessSwitch).To(Equal("allow"))
	})

	It("confirms a host-bit CIDR before posting", func() {
		service := &fakeMutationService{}
		var output, errors bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetErr(&errors)
		command.SetIn(strings.NewReader("y\n"))
		command.SetArgs([]string{"net", "add", "--institution", "7", "--cidr", "192.0.2.17/24", "--access-switch", "deny"})

		Expect(command.Execute()).To(Succeed())
		Expect(errors.String()).To(ContainSubstring("192.0.2.0/24"))
		Expect(service.cidrs).To(Equal([]string{"192.0.2.0/24"}))
		Expect(service.accessSwitch).To(Equal("deny"))
	})

	It("confirms and posts a complete range decomposition as one batch", func() {
		service := &fakeMutationService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetIn(strings.NewReader("y\n"))
		command.SetArgs([]string{"network", "add", "-i", "7", "-s", "192.0.2.1", "-e", "192.0.2.3", "-y"})

		Expect(command.Execute()).To(Succeed())
		Expect(service.cidrs).To(Equal([]string{"192.0.2.1/32", "192.0.2.2/31"}))
	})

	It("shows every CIDR and creation option in the confirmation preview", func() {
		service := &fakeMutationService{}
		var errors bytes.Buffer
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetErr(&errors)
		command.SetIn(strings.NewReader("y\n"))
		command.SetArgs([]string{"network", "add", "-i", "7", "-s", "192.0.2.1", "-e", "192.0.2.3", "-a", "deny"})

		Expect(command.Execute()).To(Succeed())
		Expect(errors.String()).To(Equal("Networks to create:\n192.0.2.1/32\n192.0.2.2/31\nConfirm network creation? [y/N]: "))
	})

	It("rejects an invalid access switch before calling the service", func() {
		service := &fakeMutationService{}
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetArgs([]string{"network", "add", "-i", "7", "-c", "192.0.2.0/24", "-a", "maybe"})

		Expect(command.Execute()).To(MatchError(`invalid access switch "maybe": must be allow or deny`))
		Expect(service.cidrs).To(BeNil())
	})

	DescribeTable("rejects invalid network creation mode", func(args []string, message string) {
		service := &fakeMutationService{}
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetArgs(args)

		Expect(command.Execute()).To(MatchError(message))
		Expect(service.cidrs).To(BeNil())
	},
		Entry("no mode", []string{"network", "add", "-i", "7"}, "exactly one complete network creation mode is required"),
		Entry("mixed mode", []string{"network", "add", "-i", "7", "-c", "192.0.2.0/24", "-s", "192.0.2.0", "-e", "192.0.2.1"}, "exactly one network creation mode is required"),
		Entry("incomplete range", []string{"network", "add", "-i", "7", "-s", "192.0.2.0"}, "exactly one complete network creation mode is required"),
	)

	It("does not post when confirmation is declined", func() {
		service := &fakeMutationService{}
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetIn(strings.NewReader("n\n"))
		command.SetArgs([]string{"network", "add", "-i", "7", "-s", "192.0.2.0", "-e", "192.0.2.1"})

		Expect(command.Execute()).To(MatchError("network creation cancelled"))
		Expect(service.cidrs).To(BeNil())
	})

	It("cancels on confirmation EOF", func() {
		service := &fakeMutationService{}
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetIn(strings.NewReader(""))
		command.SetArgs([]string{"network", "add", "-i", "7", "-s", "192.0.2.0", "-e", "192.0.2.1"})

		Expect(command.Execute()).To(MatchError("network creation cancelled"))
		Expect(service.cidrs).To(BeNil())
	})

	It("skips confirmation with --yes", func() {
		service := &fakeMutationService{}
		var errors bytes.Buffer
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetErr(&errors)
		command.SetArgs([]string{"network", "add", "-i", "7", "-s", "192.0.2.0", "-e", "192.0.2.1", "--yes"})

		Expect(command.Execute()).To(Succeed())
		Expect(errors.String()).To(BeEmpty())
	})

	It("propagates network mutation errors without output", func() {
		service := &fakeMutationService{networkErr: errors.New("invalid_parameter: network rejected")}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"network", "add", "-i", "7", "-c", "192.0.2.0/24"})

		Expect(command.Execute()).To(MatchError("invalid_parameter: network rejected"))
		Expect(output.String()).To(BeEmpty())
	})

	It("propagates duplicate CIDR owner details unchanged after canonicalization", func() {
		service := &fakeMutationService{networkErr: errors.New("invalid_parameter: cidr 192.0.2.0/24 already exists for institution 7 (Example University)")}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"network", "add", "--institution", "7", "--cidr", "192.0.2.17/24", "--yes"})

		Expect(command.Execute()).To(MatchError("invalid_parameter: cidr 192.0.2.0/24 already exists for institution 7 (Example University)"))
		Expect(service.cidrs).To(Equal([]string{"192.0.2.0/24"}))
		Expect(output.String()).To(BeEmpty())
	})

	It("renders network creation as the documented table", func() {
		service := &fakeMutationService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"network", "add", "-i", "7", "-c", "192.0.2.0/24"})

		Expect(command.Execute()).To(Succeed())
		Expect(output.String()).To(And(
			ContainSubstring("INST  DLPSCIDRADDRESS  DLPSACCESSSWITCH  DLPSADDRESSSTART  DLPSADDRESSEND  LASTMODIFIEDTIME\n"),
			ContainSubstring("8     192.0.2.0/24"),
			ContainSubstring("allow"),
		))
	})

	It("renders an empty network response without invoking an item formatter", func() {
		service := &fakeMutationService{networks: []Network{}}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "network", "add", "-i", "7", "-c", "192.0.2.0/24"})

		Expect(command.Execute()).To(Succeed())
		Expect(output.String()).To(Equal("{\"networks\":[]}\n"))
	})

	It("renders created networks as the documented JSON envelope", func() {
		service := &fakeMutationService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "network", "add", "-i", "7", "-c", "192.0.2.0/24"})

		Expect(command.Execute()).To(Succeed())
		var response networkResponse
		Expect(json.Unmarshal(output.Bytes(), &response)).To(Succeed())
		Expect(response.Networks).To(HaveLen(1))
	})
})
