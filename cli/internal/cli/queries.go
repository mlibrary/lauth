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

type Grant struct {
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
	Grants      []Grant          `json:"grants,omitempty"`
}

type Location struct {
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
	Grants     []Grant    `json:"grants,omitempty"`
}

type AccessResult struct {
	Determination         string   `json:"determination"`
	AuthorizedCollections []string `json:"authorized_collections"`
	PublicCollections     []string `json:"public_collections"`
}

type QueryService interface {
	InstitutionSearcher
	SearchNetworks(NetworkSearch) ([]Network, error)
	InstitutionNetworks(string) ([]Network, error)
	InstitutionGrants(string) ([]Grant, error)
	UserShow(string) (UserInspection, error)
	SearchLocations(string, string) ([]Location, error)
	CollectionSearch(string) ([]Collection, error)
	CollectionShow(string) (CollectionInspection, error)
	CollectionGrants(string) ([]Grant, error)
	CheckAccess(string, string, string) (AccessResult, error)
}

type MutationService interface {
	CreateInstitution(string) (Institution, error)
	CreateNetworks(string, []string, string) ([]Network, error)
}

type NetworkSearch struct {
	IP         string
	Prefix     string
	CIDR       string
	RangeStart string
	RangeEnd   string
}

type networkResponse struct {
	Networks []Network `json:"networks"`
}
type grantResponse struct {
	Grants []Grant `json:"grants"`
}
type locationResponse struct {
	Locations []Location `json:"locations"`
}
type collectionResponse struct {
	Collections []Collection `json:"collections"`
}

func addQueryCommands(root *cobra.Command, service QueryService, stdout io.Writer) {
	root.AddCommand(networkCommands(service, stdout), userCommands(service, stdout), locationCommands(service, stdout), collectionCommands(service, stdout), accessCommands(service, stdout))
	institution := findCommand(root, "institution")
	institution.AddCommand(queryCommand("networks [institution-id]", "List networks associated with an institution.", "lauth institution networks 7", func(args []string) (any, error) {
		items, err := service.InstitutionNetworks(args[0])
		return networkResponse{Networks: items}, err
	}, stdout), queryCommand("grants [institution-id]", "List collection grants for an institution.", "lauth institution grants 7", func(args []string) (any, error) {
		items, err := service.InstitutionGrants(args[0])
		return grantResponse{Grants: items}, err
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
	group := &cobra.Command{Use: "network", Aliases: []string{"net"}, Short: "Search authorization networks."}
	var search NetworkSearch
	command := &cobra.Command{
		Use:   "search",
		Short: "Search networks by IP, prefix, CIDR, or address range.",
		Args:  cobra.NoArgs,
		RunE: func(command *cobra.Command, _ []string) error {
			modes := 0
			if search.IP != "" {
				modes++
			}
			if search.Prefix != "" {
				modes++
			}
			if search.CIDR != "" {
				modes++
			}
			if search.RangeStart != "" || search.RangeEnd != "" {
				modes++
			}
			if modes != 1 || (search.RangeStart == "" && search.RangeEnd != "" || search.RangeStart != "" && search.RangeEnd == "") {
				return fmt.Errorf("exactly one complete network search mode is required")
			}
			items, err := service.SearchNetworks(search)
			if err != nil {
				return err
			}
			return renderResult(command, stdout, networkResponse{Networks: items})
		},
	}
	command.Flags().StringVar(&search.IP, "ip", "", "complete IPv4 address")
	command.Flags().StringVar(&search.Prefix, "prefix", "", "dotted IPv4 prefix")
	command.Flags().StringVar(&search.CIDR, "cidr", "", "IPv4 CIDR range")
	command.Flags().StringVar(&search.RangeStart, "range-start", "", "inclusive IPv4 range start")
	command.Flags().StringVar(&search.RangeEnd, "range-end", "", "inclusive IPv4 range end")
	group.AddCommand(command)
	return group
}

func userCommands(service QueryService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{Use: "user", Short: "Inspect user authorization data."}
	group.AddCommand(queryCommand("show [userid]", "Show a user, memberships, and direct grants.", "lauth user show alice", func(args []string) (any, error) {
		return service.UserShow(args[0])
	}, stdout))
	return group
}

func locationCommands(service QueryService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{Use: "location", Aliases: []string{"loc"}, Short: "Search protected locations."}
	var path, server string
	command := &cobra.Command{
		Use:   "search",
		Short: "Search locations by path and/or server.",
		Args:  cobra.NoArgs,
		RunE: func(command *cobra.Command, _ []string) error {
			if path == "" && server == "" {
				return fmt.Errorf("at least one of --path or --server is required")
			}
			items, err := service.SearchLocations(path, server)
			if err != nil {
				return err
			}
			return renderResult(command, stdout, locationResponse{Locations: items})
		},
	}
	command.Flags().StringVar(&path, "path", "", "location path pattern")
	command.Flags().StringVar(&server, "server", "", "location server pattern")
	group.AddCommand(command)
	return group
}

func collectionCommands(service QueryService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{Use: "collection", Aliases: []string{"coll"}, Short: "Search and inspect collections and grants."}
	group.AddCommand(queryCommand("search [pattern]", "Search collection identifiers.", "lauth collection search example*", func(args []string) (any, error) {
		items, err := service.CollectionSearch(args[0])
		return collectionResponse{Collections: items}, err
	}, stdout), queryCommand("show [collection]", "Show collection metadata and grant information.", "lauth collection show example", func(args []string) (any, error) {
		return service.CollectionShow(args[0])
	}, stdout), queryCommand("grants [collection]", "List grants for a collection.", "lauth collection grants example", func(args []string) (any, error) {
		items, err := service.CollectionGrants(args[0])
		return grantResponse{Grants: items}, err
	}, stdout))
	return group
}

func accessCommands(service QueryService, stdout io.Writer) *cobra.Command {
	group := &cobra.Command{Use: "access", Short: "Check access to collections."}
	group.AddCommand(&cobra.Command{
		Use:     "check [userid] [collection] [ip]",
		Short:   "Check access for a given IP, user, and collection.",
		Example: "lauth access check alice example 192.0.2.1",
		Args:    cobra.RangeArgs(2, 3),
		RunE: func(command *cobra.Command, args []string) error {
			ip := ""
			if len(args) == 3 {
				ip = args[2]
			}
			result, err := service.CheckAccess(args[0], args[1], ip)
			if err != nil {
				return err
			}
			return renderResult(command, stdout, result)
		},
	})
	return group
}

func queryCommand(use, short, example string, query func([]string) (any, error), stdout io.Writer) *cobra.Command {
	return &cobra.Command{
		Use: use, Short: short, Example: example, Args: cobra.ExactArgs(strings.Count(use, "[")),
		RunE: func(command *cobra.Command, args []string) error {
			result, err := query(args)
			if err != nil {
				return err
			}
			return renderResult(command, stdout, result)
		},
	}
}

func renderResult(command *cobra.Command, stdout io.Writer, result any) error {
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

func renderQueryTable(stdout io.Writer, result any) error {
	writer := tabwriter.NewWriter(stdout, 0, 4, 2, ' ', 0)
	switch value := result.(type) {
	case institutionSearchResponse:
		if _, err := fmt.Fprintln(writer, "UNIQUEIDENTIFIER\tORGANIZATIONNAME"); err != nil {
			return err
		}
		for _, item := range value.Institutions {
			if _, err := fmt.Fprintf(writer, "%d\t%s\n", item.UniqueIdentifier, item.OrganizationName); err != nil {
				return err
			}
		}
	case networkResponse:
		if _, err := fmt.Fprintln(writer, "INST\tDLPSCIDRADDRESS\tDLPSACCESSSWITCH\tDLPSADDRESSSTART\tDLPSADDRESSEND\tLASTMODIFIEDTIME"); err != nil {
			return err
		}
		for _, item := range value.Networks {
			if _, err := fmt.Fprintf(writer, "%d\t%s\t%s\t%d\t%d\t%s\n", item.Inst, item.DlpsCIDRAddress, item.DlpsAccessSwitch, item.DlpsAddressStart, item.DlpsAddressEnd, item.LastModifiedTime); err != nil {
				return err
			}
		}
	case grantResponse:
		if _, err := fmt.Fprintln(writer, "COLL\tLASTMODIFIEDTIME\tDLPSDELETED"); err != nil {
			return err
		}
		for _, item := range value.Grants {
			if _, err := fmt.Fprintf(writer, "%s\t%s\t%s\n", item.Coll, item.LastModifiedTime, item.DlpsDeleted); err != nil {
				return err
			}
		}
	case locationResponse:
		if _, err := fmt.Fprintln(writer, "DLPSPATH\tDLPSSERVER\tCOLL\tLASTMODIFIEDTIME\tDLPSDELETED"); err != nil {
			return err
		}
		for _, item := range value.Locations {
			if _, err := fmt.Fprintf(writer, "%s\t%s\t%s\t%s\t%s\n", item.DlpsPath, item.DlpsServer, item.Coll, item.LastModifiedTime, item.DlpsDeleted); err != nil {
				return err
			}
		}
	case collectionResponse:
		if _, err := fmt.Fprintln(writer, "UNIQUEIDENTIFIER"); err != nil {
			return err
		}
		for _, item := range value.Collections {
			if _, err := fmt.Fprintln(writer, item.UniqueIdentifier); err != nil {
				return err
			}
		}
	case UserInspection:
		if _, err := fmt.Fprintln(writer, "USERID"); err != nil {
			return err
		}
		if _, err := fmt.Fprintln(writer, value.UserID); err != nil {
			return err
		}
	case CollectionInspection:
		if _, err := fmt.Fprintln(writer, "UNIQUEIDENTIFIER\tCOMMONNAME\tDESCRIPTION"); err != nil {
			return err
		}
		if _, err := fmt.Fprintf(writer, "%s\t%s\t%s\n", value.Collection.UniqueIdentifier, value.Collection.CommonName, value.Collection.Description); err != nil {
			return err
		}
	case AccessResult:
		if _, err := fmt.Fprintln(writer, "DETERMINATION\tAUTHORIZED_COLLECTIONS\tPUBLIC_COLLECTIONS"); err != nil {
			return err
		}
		if _, err := fmt.Fprintf(writer, "%s\t%s\t%s\n", value.Determination, strings.Join(value.AuthorizedCollections, ","), strings.Join(value.PublicCollections, ",")); err != nil {
			return err
		}
	default:
		if _, err := fmt.Fprintln(writer, result); err != nil {
			return err
		}
	}
	return writer.Flush()
}
