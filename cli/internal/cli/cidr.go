package cli

import (
	"encoding/binary"
	"fmt"
	"io"
	"math/bits"
	"net"
	"strings"

	"github.com/spf13/cobra"
)

func cidrCommands(stdout io.Writer) *cobra.Command {
	group := &cobra.Command{
		Use:   "cidr",
		Short: "Convert between IPv4 ranges, CIDR blocks, and integers.",
	}
	group.AddCommand(
		fromRangeCommand(stdout),
		toRangeCommand(stdout),
		toIntsCommand(stdout),
	)
	return group
}

func fromRangeCommand(stdout io.Writer) *cobra.Command {
	return &cobra.Command{
		Use:     "from-range START END",
		Short:   "Convert an inclusive IPv4 range to minimal CIDR blocks.",
		Example: "authz cidr from-range 141.212.0.0 141.215.255.255",
		Args:    cobra.ExactArgs(2),
		RunE: func(_ *cobra.Command, args []string) error {
			blocks, err := decomposeCIDRRange(args[0], args[1])
			if err != nil {
				return err
			}
			for _, block := range blocks {
				if _, err := fmt.Fprintln(stdout, block); err != nil {
					return err
				}
			}
			return nil
		},
	}
}

func toRangeCommand(stdout io.Writer) *cobra.Command {
	return &cobra.Command{
		Use:     "to-range CIDR",
		Short:   "Convert an IPv4 CIDR block to its starting and ending addresses.",
		Example: "authz cidr to-range 141.212.0.0/14",
		Args:    cobra.ExactArgs(1),
		RunE: func(_ *cobra.Command, args []string) error {
			start, end, err := cidrRange(args[0])
			if err != nil {
				return err
			}
			_, err = fmt.Fprintf(stdout, "%s %s\n", formatIPv4(start), formatIPv4(end))
			return err
		},
	}
}

func toIntsCommand(stdout io.Writer) *cobra.Command {
	return &cobra.Command{
		Use:     "to-ints CIDR",
		Short:   "Convert an IPv4 CIDR block to 32-bit start and end integers.",
		Example: "authz cidr to-ints 141.212.0.0/14",
		Args:    cobra.ExactArgs(1),
		RunE: func(_ *cobra.Command, args []string) error {
			start, end, err := cidrRange(args[0])
			if err != nil {
				return err
			}
			_, err = fmt.Fprintf(stdout, "%d %d\n", start, end)
			return err
		},
	}
}

func decomposeCIDRRange(startAddress, endAddress string) ([]string, error) {
	start, err := parseIPv4(startAddress)
	if err != nil {
		return nil, fmt.Errorf("invalid start address %q: %w", startAddress, err)
	}
	end, err := parseIPv4(endAddress)
	if err != nil {
		return nil, fmt.Errorf("invalid end address %q: %w", endAddress, err)
	}
	if start > end {
		return nil, fmt.Errorf("start address %q is greater than end address %q", startAddress, endAddress)
	}

	blocks := make([]string, 0)
	for current := uint64(start); current <= uint64(end); {
		address := uint32(current)
		blockSize := uint64(1) << bits.TrailingZeros32(address)
		remaining := uint64(end) - current + 1
		for blockSize > remaining {
			blockSize >>= 1
		}
		prefix := 32 - (bits.Len64(blockSize) - 1)
		blocks = append(blocks, fmt.Sprintf("%s/%d", formatIPv4(address), prefix))
		current += blockSize
	}
	return blocks, nil
}

func parseIPv4(address string) (uint32, error) {
	if strings.Contains(address, ":") {
		return 0, fmt.Errorf("expected dotted-decimal IPv4")
	}
	ip := net.ParseIP(address)
	if ip == nil || ip.To4() == nil {
		return 0, fmt.Errorf("expected dotted-decimal IPv4")
	}
	return binary.BigEndian.Uint32(ip.To4()), nil
}

func cidrRange(block string) (uint32, uint32, error) {
	if strings.Contains(block, ":") {
		return 0, 0, fmt.Errorf("invalid CIDR block %q: expected IPv4 slash notation", block)
	}
	ip, network, err := net.ParseCIDR(block)
	if err != nil || ip.To4() == nil {
		return 0, 0, fmt.Errorf("invalid CIDR block %q: expected IPv4 slash notation", block)
	}
	ones, bits := network.Mask.Size()
	if bits != 32 {
		return 0, 0, fmt.Errorf("invalid CIDR block %q: expected IPv4 slash notation", block)
	}
	start := binary.BigEndian.Uint32(network.IP.To4())
	blockSize := uint64(1) << (32 - ones)
	end := uint32(uint64(start) + blockSize - 1)
	return start, end, nil
}

func formatIPv4(address uint32) string {
	return net.IPv4(byte(address>>24), byte(address>>16), byte(address>>8), byte(address)).String()
}
