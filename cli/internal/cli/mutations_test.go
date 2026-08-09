package cli

import (
	"bytes"
	"encoding/json"
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

type fakeMutationService struct {
	fakeQueryService
	createdInstitution string
	institutionID      string
	cidrs              []string
	accessSwitch       string
}

func (f *fakeMutationService) CreateInstitution(name string) (Institution, error) {
	f.createdInstitution = name
	return Institution{UniqueIdentifier: 8, OrganizationName: name}, nil
}

func (f *fakeMutationService) CreateNetworks(institutionID string, cidrs []string, accessSwitch string) ([]Network, error) {
	f.institutionID = institutionID
	f.cidrs = cidrs
	f.accessSwitch = accessSwitch
	return []Network{{Inst: 8, DlpsCIDRAddress: cidrs[0], DlpsAccessSwitch: accessSwitch}}, nil
}

var _ = Describe("mutation commands", func() {
	It("creates an institution through the inst alias", func() {
		service := &fakeMutationService{}
		var output bytes.Buffer
		command := NewRootCommand(service, &output)
		command.SetArgs([]string{"--output=json", "inst", "add", "Example University"})

		Expect(command.Execute()).To(Succeed())
		Expect(service.createdInstitution).To(Equal("Example University"))
		Expect(output.String()).To(ContainSubstring(`"organizationName":"Example University"`))
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

	It("does not post when confirmation is declined", func() {
		service := &fakeMutationService{}
		command := NewRootCommand(service, &bytes.Buffer{})
		command.SetIn(strings.NewReader("n\n"))
		command.SetArgs([]string{"network", "add", "-i", "7", "-s", "192.0.2.0", "-e", "192.0.2.1"})

		Expect(command.Execute()).To(MatchError("network creation cancelled"))
		Expect(service.cidrs).To(BeNil())
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
