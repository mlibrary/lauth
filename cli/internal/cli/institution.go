package cli

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"text/tabwriter"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

type Institution struct {
	UniqueIdentifier int    `json:"uniqueIdentifier"`
	OrganizationName string `json:"organizationName"`
}

type institutionSearchResponse struct {
	Institutions []Institution `json:"institutions"`
}

type InstitutionSearcher interface {
	SearchInstitutions(pattern string) ([]Institution, error)
}

type fixtureInstitutionSearcher struct {
	institutions []Institution
}

func NewFixtureInstitutionSearcher(path string) (InstitutionSearcher, error) {
	response, err := os.ReadFile(filepath.Clean(path))
	if err != nil {
		return nil, fmt.Errorf("read institution fixture: %w", err)
	}
	institutions, err := parseInstitutionSearchResponse(response)
	if err != nil {
		return nil, err
	}
	return fixtureInstitutionSearcher{institutions: institutions}, nil
}

func (f fixtureInstitutionSearcher) SearchInstitutions(_ string) ([]Institution, error) {
	return f.institutions, nil
}

func parseInstitutionSearchResponse(response []byte) ([]Institution, error) {
	var decoded institutionSearchResponse
	if err := json.Unmarshal(response, &decoded); err != nil {
		return nil, fmt.Errorf("decode institution search response: %w", err)
	}
	return decoded.Institutions, nil
}

func NewRootCommand(searcher InstitutionSearcher, stdout io.Writer) *cobra.Command {
	root := &cobra.Command{Use: "authz"}
	root.PersistentFlags().String("output", "table", "output format: table or json")
	_ = viper.BindPFlag("output", root.PersistentFlags().Lookup("output"))

	institution := &cobra.Command{Use: "institution"}
	search := &cobra.Command{
		Use:  "search [fragments...]",
		Args: cobra.MinimumNArgs(1),
		RunE: func(_ *cobra.Command, args []string) error {
			institutions, err := searcher.SearchInstitutions(strings.Join(args, "%"))
			if err != nil {
				return err
			}
			format, err := root.PersistentFlags().GetString("output")
			if err != nil {
				return err
			}
			if format == "json" {
				return json.NewEncoder(stdout).Encode(institutionSearchResponse{Institutions: institutions})
			}
			if format != "table" {
				return fmt.Errorf("unsupported output format %q", format)
			}
			return renderInstitutionTable(stdout, institutions)
		},
	}
	institution.AddCommand(search)
	root.AddCommand(institution)
	return root
}

func renderInstitutionTable(stdout io.Writer, institutions []Institution) error {
	writer := tabwriter.NewWriter(stdout, 0, 4, 2, ' ', 0)
	if _, err := fmt.Fprintln(writer, "UNIQUEIDENTIFIER\tORGANIZATIONNAME"); err != nil {
		return err
	}
	for _, institution := range institutions {
		if _, err := fmt.Fprintf(writer, "%d\t%s\n", institution.UniqueIdentifier, institution.OrganizationName); err != nil {
			return err
		}
	}
	return writer.Flush()
}
