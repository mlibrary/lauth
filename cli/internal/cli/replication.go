package cli

import (
	"io"

	"github.com/spf13/cobra"
)

type ReplicationService interface {
	ReplicationStatus() (map[string]any, error)
}

func replicationCommands(service ReplicationService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{
		Use:   "replication",
		Short: "Inspect replication health.",
	}
	group.AddCommand(mapQueryCommand(
		"status",
		"Report replication status and health.",
		"Fetch replication health from the REST API.",
		"authz replication status",
		service.ReplicationStatus,
		stdout,
	))
	return group
}
