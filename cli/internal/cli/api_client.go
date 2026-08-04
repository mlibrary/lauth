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

const defaultAPIBaseURL = "http://localhost:8080"

type APIClient struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

var _ QueryService = (*APIClient)(nil)

func NewAPIClient(baseURL, apiKey string, httpClient *http.Client) *APIClient {
	if httpClient == nil {
		httpClient = &http.Client{Timeout: 30 * time.Second}
	}
	return &APIClient{
		baseURL:    strings.TrimRight(baseURL, "/"),
		apiKey:     apiKey,
		httpClient: httpClient,
	}
}

func NewAPIClientFromConfig() *APIClient {
	configureEnvironment()
	baseURL := viper.GetString("api-base-url")
	if baseURL == "" {
		baseURL = defaultAPIBaseURL
	}
	timeout := viper.GetDuration("api-timeout")
	if timeout <= 0 {
		timeout = 30 * time.Second
	}
	return NewAPIClient(baseURL, viper.GetString("api-key"), &http.Client{Timeout: timeout})
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

func (c *APIClient) SearchNetworks(prefix string) ([]Network, error) {
	var response struct {
		Networks []Network `json:"networks"`
	}
	if err := c.get("/networks", url.Values{"cidr": {prefix}}, &response); err != nil {
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

func (c *APIClient) InstitutionCollections(institutionID string) ([]Access, error) {
	var response struct {
		Collections []Access `json:"collections"`
	}
	if err := c.get("/institutions/"+url.PathEscape(institutionID)+"/collections", nil, &response); err != nil {
		return nil, err
	}
	return response.Collections, nil
}

func (c *APIClient) UserShow(userID string) (UserInspection, error) {
	var response UserInspection
	if err := c.get("/users/"+url.PathEscape(userID), nil, &response); err != nil {
		return UserInspection{}, err
	}
	return response, nil
}

func (c *APIClient) ObjectsByPath(path string) ([]CollectionObject, error) {
	var response struct {
		Objects []CollectionObject `json:"objects"`
	}
	if err := c.get("/objects", url.Values{"path": {path}}, &response); err != nil {
		return nil, err
	}
	return response.Objects, nil
}

func (c *APIClient) ObjectsByServer(server string) ([]CollectionObject, error) {
	var response struct {
		Objects []CollectionObject `json:"objects"`
	}
	if err := c.get("/objects", url.Values{"server": {server}}, &response); err != nil {
		return nil, err
	}
	return response.Objects, nil
}

func (c *APIClient) CollectionShow(collection string) (CollectionInspection, error) {
	var response CollectionInspection
	if err := c.get("/collections/"+url.PathEscape(collection), nil, &response); err != nil {
		return CollectionInspection{}, err
	}
	return response, nil
}

func (c *APIClient) CollectionAccess(collection string) ([]Access, error) {
	var response struct {
		Access []Access `json:"access"`
	}
	if err := c.get("/collections/"+url.PathEscape(collection)+"/access", nil, &response); err != nil {
		return nil, err
	}
	return response.Access, nil
}

func (c *APIClient) AuthzDiagnostic(ip, userID, collection string) (AuthzDiagnostic, error) {
	var response AuthzDiagnostic
	query := url.Values{
		"ip":         {ip},
		"userid":     {userID},
		"collection": {collection},
	}
	if err := c.get("/authzd_to_coll", query, &response); err != nil {
		return AuthzDiagnostic{}, err
	}
	return response, nil
}

func (c *APIClient) get(path string, query url.Values, target any) error {
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
	if c.apiKey != "" {
		request.Header.Set("X-API-Key", c.apiKey)
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
		return fmt.Errorf("API request failed with status %s: %s", response.Status, strings.TrimSpace(string(body)))
	}
	if err := json.NewDecoder(response.Body).Decode(target); err != nil {
		return fmt.Errorf("decode API response: %w", err)
	}
	return nil
}
