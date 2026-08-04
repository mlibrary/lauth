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
		command.SetArgs([]string{"cidr", "from-range", start, end})

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

	DescribeTable("converts CIDR blocks to address ranges", func(block, expected string) {
		var output bytes.Buffer
		command := NewRootCommand(&fakeQueryService{}, &output)
		command.SetArgs([]string{"cidr", "to-range", block})

		Expect(command.Execute()).To(Succeed())
		Expect(strings.TrimSpace(output.String())).To(Equal(expected))
	},
		Entry("a /24", "192.0.2.0/24", "192.0.2.0 192.0.2.255"),
		Entry("the full IPv4 space", "0.0.0.0/0", "0.0.0.0 255.255.255.255"),
		Entry("a single address", "192.0.2.1/32", "192.0.2.1 192.0.2.1"),
	)

	DescribeTable("converts CIDR blocks to integer ranges", func(block, expected string) {
		var output bytes.Buffer
		command := NewRootCommand(&fakeQueryService{}, &output)
		command.SetArgs([]string{"cidr", "to-ints", block})

		Expect(command.Execute()).To(Succeed())
		Expect(strings.TrimSpace(output.String())).To(Equal(expected))
	},
		Entry("a /24", "192.0.2.0/24", "3221225984 3221226239"),
		Entry("the full IPv4 space", "0.0.0.0/0", "0 4294967295"),
		Entry("a single address", "192.0.2.1/32", "3221225985 3221225985"),
	)

	DescribeTable("rejects invalid input", func(args []string) {
		var output bytes.Buffer
		command := NewRootCommand(&fakeQueryService{}, &output)
		command.SetArgs(append([]string{"cidr"}, args...))

		Expect(command.Execute()).NotTo(Succeed())
	},
		Entry("reversed range", []string{"from-range", "192.0.2.2", "192.0.2.1"}),
		Entry("invalid octet", []string{"from-range", "192.0.2.256", "192.0.2.257"}),
		Entry("invalid CIDR", []string{"to-range", "192.0.2.0/33"}),
		Entry("missing prefix", []string{"to-ints", "192.0.2.0"}),
		Entry("IPv6 block", []string{"to-range", "2001:db8::/32"}),
	)
})
