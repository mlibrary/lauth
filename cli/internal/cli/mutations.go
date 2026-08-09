package cli

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"strings"

	"github.com/spf13/cobra"
)

func addMutationCommands(root *cobra.Command, service MutationService, stdout io.Writer) {
	institution := findCommand(root, "institution")
	institution.AddCommand(&cobra.Command{
		Use:   "add [organization-name]",
		Short: "Create an active institution.",
		Args:  cobra.ExactArgs(1),
		RunE: func(command *cobra.Command, args []string) error {
			if strings.TrimSpace(args[0]) == "" {
				return fmt.Errorf("organization name cannot be empty")
			}
			created, err := service.CreateInstitution(args[0])
			if err != nil {
				return err
			}
			return renderMutationResult(command, stdout, institutionSearchResponse{Institutions: []Institution{created}})
		},
	})

	network := findCommand(root, "network")
	network.AddCommand(networkCreateCommand(service, stdout))
}

func networkCreateCommand(service MutationService, stdout io.Writer) *cobra.Command {
	var institutionID, cidr, rangeStart, rangeEnd, accessSwitch string
	var assumeYes bool
	command := &cobra.Command{
		Use:   "add",
		Short: "Create an institution-associated network batch.",
		Args:  cobra.NoArgs,
		RunE: func(command *cobra.Command, _ []string) error {
			if institutionID == "" {
				return fmt.Errorf("--institution is required")
			}
			if accessSwitch != "allow" && accessSwitch != "deny" {
				return fmt.Errorf("invalid access switch %q: must be allow or deny", accessSwitch)
			}
			cidrs, requiresConfirmation, err := networkCIDRs(cidr, rangeStart, rangeEnd)
			if err != nil {
				return err
			}
			if requiresConfirmation && !assumeYes {
				if err := confirmNetworks(command, cidrs); err != nil {
					return err
				}
			}
			created, err := service.CreateNetworks(institutionID, cidrs, accessSwitch)
			if err != nil {
				return err
			}
			return renderMutationResult(command, stdout, networkResponse{Networks: created})
		},
	}
	command.Flags().StringVarP(&institutionID, "institution", "i", "", "institution ID")
	command.Flags().StringVarP(&cidr, "cidr", "c", "", "IPv4 CIDR")
	command.Flags().StringVarP(&rangeStart, "range-start", "s", "", "inclusive IPv4 range start")
	command.Flags().StringVarP(&rangeEnd, "range-end", "e", "", "inclusive IPv4 range end")
	command.Flags().StringVarP(&accessSwitch, "access-switch", "a", "allow", "network access switch: allow or deny")
	command.Flags().BoolVarP(&assumeYes, "yes", "y", false, "confirm canonicalization or range creation")
	return command
}

func networkCIDRs(cidr, rangeStart, rangeEnd string) ([]string, bool, error) {
	if cidr != "" && (rangeStart != "" || rangeEnd != "") {
		return nil, false, fmt.Errorf("exactly one network creation mode is required")
	}
	if cidr != "" {
		canonical, err := canonicalCIDR(cidr)
		if err != nil {
			return nil, false, err
		}
		return []string{canonical}, strings.TrimSpace(cidr) != canonical, nil
	}
	if rangeStart == "" || rangeEnd == "" {
		return nil, false, fmt.Errorf("exactly one complete network creation mode is required")
	}
	blocks, err := decomposeCIDRRange(rangeStart, rangeEnd)
	return blocks, true, err
}

func confirmNetworks(command *cobra.Command, cidrs []string) error {
	output := command.ErrOrStderr()
	fmt.Fprintln(output, "Networks to create:")
	for _, cidr := range cidrs {
		fmt.Fprintln(output, cidr)
	}
	fmt.Fprint(output, "Confirm network creation? [y/N]: ")
	answer, err := bufio.NewReader(command.InOrStdin()).ReadString('\n')
	if err != nil {
		return fmt.Errorf("network creation cancelled")
	}
	if strings.ToLower(strings.TrimSpace(answer)) != "y" {
		return fmt.Errorf("network creation cancelled")
	}
	return nil
}

func renderMutationResult(command *cobra.Command, stdout io.Writer, result any) error {
	format, err := command.Root().PersistentFlags().GetString("output")
	if err != nil {
		return err
	}
	if format == "json" {
		return json.NewEncoder(stdout).Encode(result)
	}
	if format != "table" {
		return fmt.Errorf("unsupported output format %q", format)
	}
	return renderQueryTable(stdout, result)
}
