package cli

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/spf13/viper"
)

const defaultAPITimeout = 10 * time.Second

type APIClient struct {
	baseURL    string
	token      string
	httpClient *http.Client
}

var _ QueryService = (*APIClient)(nil)

func NewAPIClient(baseURL, token string, httpClient *http.Client) *APIClient {
	if httpClient == nil {
		httpClient = &http.Client{Timeout: defaultAPITimeout}
	}
	return &APIClient{
		baseURL:    strings.TrimRight(baseURL, "/"),
		token:      token,
		httpClient: httpClient,
	}
}

func NewAPIClientFromConfig() *APIClient {
	configureEnvironment()
	timeout := viper.GetDuration("api-timeout")
	if timeout <= 0 {
		timeout = defaultAPITimeout
	}
	return NewAPIClient(viper.GetString("api-base-url"), viper.GetString("api-token"), &http.Client{Timeout: timeout})
}

func (c *APIClient) configure(baseURL, token, timeout string) error {
	if baseURL != "" {
		c.baseURL = strings.TrimRight(baseURL, "/")
	}
	if token != "" {
		c.token = token
	}
	if timeout != "" {
		parsed, err := time.ParseDuration(timeout)
		if err != nil || parsed <= 0 {
			return fmt.Errorf("invalid API timeout %q", timeout)
		}
		c.httpClient.Timeout = parsed
	}
	return nil
}

func configureEnvironment() {
	viper.SetEnvPrefix("AUTHZ")
	viper.SetEnvKeyReplacer(strings.NewReplacer("-", "_"))
	viper.AutomaticEnv()
}

func (c *APIClient) SearchInstitutions(pattern string) ([]Institution, error) {
	var response institutionSearchResponse
	if err := c.get("/institutions", url.Values{"organizationName": {pattern}}, &response); err != nil {
		return nil, err
	}
	return response.Institutions, nil
}

func (c *APIClient) SearchNetworks(search NetworkSearch) ([]Network, error) {
	query := url.Values{}
	switch {
	case search.IP != "":
		query.Set("ip", search.IP)
	case search.Prefix != "":
		query.Set("prefix", search.Prefix)
	case search.CIDR != "":
		query.Set("cidr", search.CIDR)
	default:
		query.Set("rangeStart", search.RangeStart)
		query.Set("rangeEnd", search.RangeEnd)
	}
	var response struct {
		Networks []Network `json:"networks"`
	}
	if err := c.get("/networks", query, &response); err != nil {
		return nil, err
	}
	return response.Networks, nil
}

func (c *APIClient) InstitutionNetworks(institutionID string) ([]Network, error) {
	var response struct {
		Networks []Network `json:"networks"`
	}
	if err := c.get("/institutions/"+url.PathEscape(institutionID)+"/networks", nil, &response); err != nil {
		return nil, err
	}
	return response.Networks, nil
}

func (c *APIClient) InstitutionGrants(institutionID string) ([]Grant, error) {
	var response struct {
		Grants []Grant `json:"grants"`
	}
	if err := c.get("/institutions/"+url.PathEscape(institutionID)+"/grants", nil, &response); err != nil {
		return nil, err
	}
	return response.Grants, nil
}

func (c *APIClient) UserShow(userID string) (UserInspection, error) {
	var response UserInspection
	if err := c.get("/users/"+url.PathEscape(userID), nil, &response); err != nil {
		return UserInspection{}, err
	}
	return response, nil
}

func (c *APIClient) SearchLocations(path, server string) ([]Location, error) {
	query := url.Values{}
	if path != "" {
		query.Set("path", path)
	}
	if server != "" {
		query.Set("server", server)
	}
	var response struct {
		Locations []Location `json:"locations"`
	}
	if err := c.get("/locations", query, &response); err != nil {
		return nil, err
	}
	return response.Locations, nil
}

func (c *APIClient) CollectionSearch(pattern string) ([]Collection, error) {
	var response struct {
		Collections []Collection `json:"collections"`
	}
	if err := c.get("/collections", url.Values{"id": {pattern}}, &response); err != nil {
		return nil, err
	}
	return response.Collections, nil
}

func (c *APIClient) CollectionShow(collection string) (CollectionInspection, error) {
	var response CollectionInspection
	if err := c.get("/collections/"+url.PathEscape(collection), nil, &response); err != nil {
		return CollectionInspection{}, err
	}
	return response, nil
}

func (c *APIClient) CollectionGrants(collection string) ([]Grant, error) {
	var response struct {
		Grants []Grant `json:"grants"`
	}
	if err := c.get("/collections/"+url.PathEscape(collection)+"/grants", nil, &response); err != nil {
		return nil, err
	}
	return response.Grants, nil
}

// AuthzDiagnostic remains on the deferred legacy contract until its necessity is decided.
func (c *APIClient) AuthzDiagnostic(ip, userID, collection string) (AuthzDiagnostic, error) {
	var response AuthzDiagnostic
	query := url.Values{"ip": {ip}, "userid": {userID}, "collection": {collection}}
	if err := c.getLegacy("/authzd_to_coll", query, &response); err != nil {
		return AuthzDiagnostic{}, err
	}
	return response, nil
}

func (c *APIClient) get(path string, query url.Values, target any) error {
	return c.request("/api/v1"+path, query, target, true)
}

func (c *APIClient) getLegacy(path string, query url.Values, target any) error {
	return c.request(path, query, target, false)
}

func (c *APIClient) request(path string, query url.Values, target any, bearer bool) error {
	if c.baseURL == "" {
		return fmt.Errorf("AUTHZ_API_BASE_URL is required")
	}
	if c.token == "" {
		return fmt.Errorf("AUTHZ_API_TOKEN is required")
	}
	requestURL, err := url.Parse(c.baseURL + path)
	if err != nil {
		return fmt.Errorf("build API request: %w", err)
	}
	requestURL.RawQuery = query.Encode()
	request, err := http.NewRequest(http.MethodGet, requestURL.String(), nil)
	if err != nil {
		return fmt.Errorf("build API request: %w", err)
	}
	request.Header.Set("Accept", "application/json")
	if bearer {
		request.Header.Set("Authorization", "Bearer "+c.token)
	} else {
		request.Header.Set("X-API-Key", c.token)
	}

	response, err := c.httpClient.Do(request)
	if err != nil {
		return fmt.Errorf("API request: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode < http.StatusOK || response.StatusCode >= http.StatusMultipleChoices {
		body, readErr := io.ReadAll(io.LimitReader(response.Body, 4<<10))
		if readErr != nil {
			return fmt.Errorf("API request failed with status %s: read error: %w", response.Status, readErr)
		}
		var apiError struct {
			Error struct {
				Code    string `json:"code"`
				Message string `json:"message"`
			} `json:"error"`
		}
		if json.Unmarshal(body, &apiError) == nil && apiError.Error.Message != "" {
			return fmt.Errorf("%s: %s", apiError.Error.Code, apiError.Error.Message)
		}
		return fmt.Errorf("API request failed with status %s", response.Status)
	}
	if err := json.NewDecoder(response.Body).Decode(target); err != nil {
		return fmt.Errorf("decode API response: %w", err)
	}
	return nil
}
