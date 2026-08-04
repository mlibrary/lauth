package cli

import (
	"bytes"
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("cidr", func() {
	DescribeTable("decomposes inclusive IPv4 ranges", func(start, end string, expected []string) {
		var output bytes.Buffer
		command := NewRootCommand(&fakeQueryService{}, &output)
		command.SetArgs([]string{"cidr", start, "-", end})

		Expect(command.Execute()).To(Succeed())
		Expect(strings.Split(strings.TrimSpace(output.String()), "\n")).To(Equal(expected))
	},
		Entry("single address", "192.0.2.1", "192.0.2.1", []string{"192.0.2.1/32"}),
		Entry("aligned /24", "192.0.2.0", "192.0.2.255", []string{"192.0.2.0/24"}),
		Entry("crosses an octet boundary", "192.0.2.0", "192.0.3.255", []string{"192.0.2.0/23"}),
		Entry("unaligned range", "192.0.2.1", "192.0.2.3", []string{"192.0.2.1/32", "192.0.2.2/31"}),
		Entry("begins at zero", "0.0.0.0", "0.0.0.255", []string{"0.0.0.0/24"}),
		Entry("ends at the maximum address", "255.255.255.254", "255.255.255.255", []string{"255.255.255.254/31"}),
		Entry("full IPv4 space", "0.0.0.0", "255.255.255.255", []string{"0.0.0.0/0"}),
	)

	DescribeTable("rejects invalid ranges", func(args []string) {
		var output bytes.Buffer
		command := NewRootCommand(&fakeQueryService{}, &output)
		command.SetArgs(append([]string{"cidr"}, args...))

		Expect(command.Execute()).NotTo(Succeed())
	},
		Entry("reversed range", []string{"192.0.2.2", "-", "192.0.2.1"}),
		Entry("invalid octet", []string{"192.0.2.256", "-", "192.0.2.257"}),
		Entry("missing separator", []string{"192.0.2.1", "192.0.2.2"}),
		Entry("malformed separator", []string{"192.0.2.1", "--", "192.0.2.2"}),
	)
})
