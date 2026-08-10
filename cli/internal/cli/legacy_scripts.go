package cli

import (
	"fmt"
	"io"

	"github.com/spf13/cobra"
)

type legacyScriptMapping struct {
	legacy      string
	command     string
	description string
}

var legacyScriptMappings = []legacyScriptMapping{
	{legacy: "qi", command: "institution search", description: "Search institutions by organization-name pattern."},
	{legacy: "qn", command: "network search", description: "Search authorization networks."},
	{legacy: "qin", command: "institution networks", description: "List networks associated with an institution."},
	{legacy: "qic", command: "institution grants", description: "List collection grants for an institution."},
	{legacy: "qu", command: "user show", description: "Show a user, memberships, and direct grants."},
	{legacy: "qp", command: "location search", description: "Search protected locations by path."},
	{legacy: "qs", command: "location search", description: "Search protected locations by server."},
	{legacy: "qc", command: "collection show / collection grants", description: "Show collection metadata and matching grants."},
	{legacy: "authzd_to_coll", command: "access check", description: "Check access for a given IP, user, and collection."},
	{legacy: "ain", command: "network add", description: "Create an institution-associated network batch."},
	{legacy: "add_inst", command: "institution add", description: "Create an active institution."},
}

func legacyScriptsCommand(stdout io.Writer) *cobra.Command {
	return &cobra.Command{
		Use:   "legacy-scripts",
		Short: "Show legacy script command equivalents.",
		Args:  cobra.NoArgs,
		RunE: func(_ *cobra.Command, _ []string) error {
			if _, err := fmt.Fprintln(stdout, "Legacy scripts with command equivalents:"); err != nil {
				return err
			}
			for _, mapping := range legacyScriptMappings {
				if _, err := fmt.Fprintf(stdout, "  %-16s %-32s %s\n", mapping.legacy, mapping.command, mapping.description); err != nil {
					return err
				}
			}
			return nil
		},
	}
}
