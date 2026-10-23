package cli

import (
	"encoding/json"
	"fmt"
	"io"

	"github.com/spf13/cobra"
)

// renderOutput applies the CLI's shared output contract to query and mutation
// results. Resource-specific table formatting remains in renderQueryTable.
func renderOutput(command *cobra.Command, stdout io.Writer, result any) error {
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
