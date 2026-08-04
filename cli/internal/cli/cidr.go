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

func cidrCommand(stdout io.Writer) *cobra.Command {
	command := &cobra.Command{
		Use:     "cidr START - END",
		Short:   "Convert an inclusive IPv4 range to minimal CIDR blocks.",
		Example: "authz cidr 141.212.0.0 - 141.215.255.255",
		Args:    cobra.ExactArgs(3),
		RunE: func(_ *cobra.Command, args []string) error {
			if args[1] != "-" {
				return fmt.Errorf("range separator must be '-'")
			}
			blocks, err := decomposeCIDRRange(args[0], args[2])
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
	return command
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

func formatIPv4(address uint32) string {
	return net.IPv4(byte(address>>24), byte(address>>16), byte(address>>8), byte(address)).String()
}
