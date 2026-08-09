package cli

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
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
	root := &cobra.Command{
		Use:     "authz",
		Short:   "Query authorization data.",
		Long:    "Query authorization data from the REST API. Results use legacy-compatible tables by default; add --output=json for the complete API response. Configure the API with AUTHZ_API_BASE_URL, AUTHZ_API_TOKEN, and AUTHZ_API_TIMEOUT.",
		Example: "  authz institution search Michigan\n  authz --output=json user show alice",
	}
	root.PersistentFlags().String("output", "table", "output format: table or json")
	_ = viper.BindPFlag("output", root.PersistentFlags().Lookup("output"))
	root.PersistentFlags().String("api-base-url", "", "API server root (overrides AUTHZ_API_BASE_URL)")
	root.PersistentFlags().String("api-token", "", "API Bearer token (overrides AUTHZ_API_TOKEN)")
	root.PersistentFlags().String("api-timeout", "", "API timeout as a Go duration (overrides AUTHZ_API_TIMEOUT)")
	root.PersistentPreRunE = func(_ *cobra.Command, _ []string) error {
		client, ok := searcher.(*APIClient)
		if !ok {
			return nil
		}
		baseURL, _ := root.PersistentFlags().GetString("api-base-url")
		token, _ := root.PersistentFlags().GetString("api-token")
		timeout, _ := root.PersistentFlags().GetString("api-timeout")
		return client.configure(baseURL, token, timeout)
	}

	institution := &cobra.Command{
		Use:   "institution",
		Short: "Look up institutions and their associated resources.",
	}
	search := &cobra.Command{
		Use:     "search [pattern]",
		Short:   "Search institutions by organization-name pattern.",
		Example: "  authz institution search 'Michigan*'",
		Args:    cobra.ExactArgs(1),
		RunE: func(_ *cobra.Command, args []string) error {
			institutions, err := searcher.SearchInstitutions(args[0])
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
	root.AddCommand(cidrCommands(stdout))
	if service, ok := searcher.(QueryService); ok {
		addQueryCommands(root, service, stdout)
	}
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
