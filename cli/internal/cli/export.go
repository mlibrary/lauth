package cli

import (
	"encoding/json"
	"fmt"
	"io"

	"github.com/spf13/cobra"
)

type ExportService interface {
	Export() (map[string]any, error)
}

func exportCommand(service ExportService, stdout io.Writer) *cobra.Command {
	return &cobra.Command{
		Use:     "export",
		Short:   "Export authorization data from the REST API.",
		Long:    "Fetch the authorization export from the REST API and write it to standard output.",
		Example: "authz --output=json export",
		Args:    cobra.NoArgs,
		RunE: func(command *cobra.Command, _ []string) error {
			export, err := service.Export()
			if err != nil {
				return err
			}
			format, err := command.Root().PersistentFlags().GetString("output")
			if err != nil {
				return err
			}
			if format == "json" {
				return json.NewEncoder(stdout).Encode(export)
			}
			if format != "table" {
				return fmt.Errorf("unsupported output format %q", format)
			}
			return renderQueryTable(stdout, export)
		},
	}
}
