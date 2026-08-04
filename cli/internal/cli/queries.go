package cli

import (
	"encoding/json"
	"fmt"
	"io"
	"strings"
	"text/tabwriter"

	"github.com/spf13/cobra"
)

type Network struct {
	UniqueIdentifier int    `json:"uniqueIdentifier,omitempty"`
	DlpsCIDRAddress  string `json:"dlpsCIDRAddress"`
	DlpsAccessSwitch string `json:"dlpsAccessSwitch"`
	DlpsAddressStart uint32 `json:"dlpsAddressStart,omitempty"`
	DlpsAddressEnd   uint32 `json:"dlpsAddressEnd,omitempty"`
	Inst             int    `json:"inst,omitempty"`
	LastModifiedTime string `json:"lastModifiedTime,omitempty"`
}

type Access struct {
	UniqueIdentifier int    `json:"uniqueIdentifier,omitempty"`
	UserID           string `json:"userid,omitempty"`
	UserGroup        int    `json:"user_grp,omitempty"`
	Inst             int    `json:"inst,omitempty"`
	Coll             string `json:"coll"`
	LastModifiedTime string `json:"lastModifiedTime,omitempty"`
	DlpsDeleted      string `json:"dlpsDeleted,omitempty"`
}

type UserInspection struct {
	UserID      string           `json:"userid"`
	User        map[string]any   `json:"user,omitempty"`
	Memberships []map[string]any `json:"memberships,omitempty"`
	Collections []Access         `json:"collections,omitempty"`
}

type CollectionObject struct {
	DlpsServer       string `json:"dlpsServer"`
	DlpsPath         string `json:"dlpsPath"`
	Coll             string `json:"coll,omitempty"`
	LastModifiedTime string `json:"lastModifiedTime,omitempty"`
	DlpsDeleted      string `json:"dlpsDeleted,omitempty"`
}

type Collection struct {
	UniqueIdentifier string `json:"uniqueIdentifier"`
	CommonName       string `json:"commonName,omitempty"`
	Description      string `json:"description,omitempty"`
	DlpsClass        string `json:"dlpsClass,omitempty"`
	DlpsSource       string `json:"dlpsSource,omitempty"`
	DlpsAuthenMethod string `json:"dlpsAuthenMethod,omitempty"`
	DlpsAuthzType    string `json:"dlpsAuthzType,omitempty"`
	DlpsPartlyPublic string `json:"dlpsPartlyPublic,omitempty"`
}

type CollectionInspection struct {
	Collection Collection `json:"collection"`
	Access     []Access   `json:"access,omitempty"`
}

type AuthzDiagnostic struct {
	Authorized           bool   `json:"authorized"`
	AuthorizedCollection string `json:"authorizedCollection,omitempty"`
	PublicCollection     string `json:"publicCollection,omitempty"`
}

type QueryService interface {
	InstitutionSearcher
	SearchNetworks(string) ([]Network, error)
	InstitutionNetworks(string) ([]Network, error)
	InstitutionCollections(string) ([]Access, error)
	UserShow(string) (UserInspection, error)
	ObjectsByPath(string) ([]CollectionObject, error)
	ObjectsByServer(string) ([]CollectionObject, error)
	CollectionShow(string) (CollectionInspection, error)
	CollectionAccess(string) ([]Access, error)
	AuthzDiagnostic(string, string, string) (AuthzDiagnostic, error)
}

func addQueryCommands(root *cobra.Command, service QueryService, stdout io.Writer) {
	root.AddCommand(networkCommands(service, stdout), userCommands(service, stdout), objectsCommands(service, stdout), collectionCommands(service, stdout), authzCommand(service, stdout))
	institution := findCommand(root, "institution")
	institution.AddCommand(queryCommand("networks [institution-id]", func(args []string) (any, error) {
		return service.InstitutionNetworks(args[0])
	}, stdout), queryCommand("collections [institution-id]", func(args []string) (any, error) {
		return service.InstitutionCollections(args[0])
	}, stdout))
}

func findCommand(root *cobra.Command, use string) *cobra.Command {
	for _, command := range root.Commands() {
		if command.Use == use {
			return command
		}
	}
	return nil
}

func networkCommands(service QueryService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{Use: "network"}
	group.AddCommand(queryCommand("search [prefix]", func(args []string) (any, error) {
		return service.SearchNetworks(args[0] + "%")
	}, stdout))
	return group
}

func userCommands(service QueryService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{Use: "user"}
	group.AddCommand(queryCommand("show [userid]", func(args []string) (any, error) {
		return service.UserShow(args[0])
	}, stdout))
	return group
}

func objectsCommands(service QueryService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{Use: "objects"}
	group.AddCommand(queryCommand("by-path [path]", func(args []string) (any, error) {
		return service.ObjectsByPath(args[0] + "%")
	}, stdout), queryCommand("by-server [server]", func(args []string) (any, error) {
		return service.ObjectsByServer(args[0] + "%")
	}, stdout))
	return group
}

func collectionCommands(service QueryService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{Use: "collection"}
	group.AddCommand(queryCommand("show [collection]", func(args []string) (any, error) {
		return service.CollectionShow(args[0] + "%")
	}, stdout), queryCommand("access [collection]", func(args []string) (any, error) {
		return service.CollectionAccess(args[0] + "%")
	}, stdout))
	return group
}

func authzCommand(service QueryService, stdout io.Writer) *cobra.Command {
	return queryCommand("authzd_to_coll [ip] [userid] [collection]", func(args []string) (any, error) {
		return service.AuthzDiagnostic(args[0], args[1], args[2])
	}, stdout)
}

func queryCommand(use string, query func([]string) (any, error), stdout io.Writer) *cobra.Command {
	return &cobra.Command{
		Use:  use,
		Args: cobra.MinimumNArgs(strings.Count(use, "[")),
		RunE: func(command *cobra.Command, args []string) error {
			result, err := query(args)
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
			return renderQueryTable(stdout, result)
		},
	}
}

func renderQueryTable(stdout io.Writer, result any) error {
	writer := tabwriter.NewWriter(stdout, 0, 4, 2, ' ', 0)
	if _, err := fmt.Fprintln(writer, "RESULT\tVALUE"); err != nil {
		return err
	}
	if _, err := fmt.Fprintf(writer, "DATA\t%v\n", result); err != nil {
		return err
	}
	return writer.Flush()
}
