package cli

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

type fixtureQueryService struct {
	plans map[string][]byte
}

func NewFixtureQueryService(dir string) (QueryService, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("read query fixtures: %w", err)
	}
	plans := make(map[string][]byte)
	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".json" {
			continue
		}
		contents, err := os.ReadFile(filepath.Join(dir, entry.Name()))
		if err != nil {
			return nil, fmt.Errorf("read query fixture %q: %w", entry.Name(), err)
		}
		plans[entry.Name()] = contents
	}
	return fixtureQueryService{plans: plans}, nil
}

func (f fixtureQueryService) decode(name string, target any) error {
	contents, ok := f.plans[name+".json"]
	if !ok {
		return fmt.Errorf("no query fixture for %q", name)
	}
	if err := json.Unmarshal(contents, target); err != nil {
		return fmt.Errorf("decode query fixture %q: %w", name, err)
	}
	return nil
}

func (f fixtureQueryService) SearchInstitutions(string) ([]Institution, error) {
	var response institutionSearchResponse
	if err := f.decode("institution_search_response", &response); err != nil {
		return nil, err
	}
	return response.Institutions, nil
}

func (f fixtureQueryService) SearchNetworks(NetworkSearch) ([]Network, error) {
	var response struct {
		Networks []Network `json:"networks"`
	}
	if err := f.decode("network_search_response", &response); err != nil {
		return nil, err
	}
	return response.Networks, nil
}

func (f fixtureQueryService) InstitutionNetworks(string) ([]Network, error) {
	var response struct {
		Networks []Network `json:"networks"`
	}
	if err := f.decode("institution_networks_response", &response); err != nil {
		return nil, err
	}
	return response.Networks, nil
}

func (f fixtureQueryService) InstitutionGrants(string) ([]Grant, error) {
	var response struct {
		Grants []Grant `json:"grants"`
	}
	if err := f.decode("institution_grants_response", &response); err != nil {
		return nil, err
	}
	return response.Grants, nil
}

func (f fixtureQueryService) UserShow(string) (UserInspection, error) {
	var response UserInspection
	if err := f.decode("user_show_response", &response); err != nil {
		return UserInspection{}, err
	}
	return response, nil
}

func (f fixtureQueryService) SearchLocations(path, server string) ([]Location, error) {
	var response struct {
		Locations []Location `json:"locations"`
	}
	fixture := "locations_search_response"
	if server != "" {
		fixture = "locations_search_response"
	}
	if err := f.decode(fixture, &response); err != nil {
		return nil, err
	}
	return response.Locations, nil
}

func (f fixtureQueryService) CollectionSearch(string) ([]Collection, error) {
	var response struct {
		Collections []Collection `json:"collections"`
	}
	if err := f.decode("collection_search_response", &response); err != nil {
		return nil, err
	}
	return response.Collections, nil
}

func (f fixtureQueryService) CollectionShow(string) (CollectionInspection, error) {
	var response CollectionInspection
	if err := f.decode("collection_show_response", &response); err != nil {
		return CollectionInspection{}, err
	}
	return response, nil
}

func (f fixtureQueryService) CollectionGrants(string) ([]Grant, error) {
	var response struct {
		Grants []Grant `json:"grants"`
	}
	if err := f.decode("collection_grants_response", &response); err != nil {
		return nil, err
	}
	return response.Grants, nil
}

func (f fixtureQueryService) CheckAccess(string, string, string) (AccessResult, error) {
	var response AccessResult
	if err := f.decode("access_response", &response); err != nil {
		return AccessResult{}, err
	}
	return response, nil
}
