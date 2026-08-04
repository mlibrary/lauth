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
	return mapQueryCommand("export", "Export authorization data from the REST API.", "Fetch the authorization export from the REST API and write it to standard output.", "authz --output=json export", service.Export, stdout)
}

func mapQueryCommand(use, short, long, example string, query func() (map[string]any, error), stdout io.Writer) *cobra.Command {
	return &cobra.Command{
		Use:     use,
		Short:   short,
		Long:    long,
		Example: example,
		Args:    cobra.NoArgs,
		RunE: func(command *cobra.Command, _ []string) error {
			result, err := query()
			if err != nil {
				return err
			}
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
		},
	}
}
