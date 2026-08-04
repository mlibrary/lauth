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

func (f fixtureQueryService) SearchNetworks(string) ([]Network, error) {
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

func (f fixtureQueryService) InstitutionGrants(string) ([]Access, error) {
	var response struct {
		Collections []Access `json:"collections"`
	}
	if err := f.decode("institution_collections_response", &response); err != nil {
		return nil, err
	}
	return response.Collections, nil
}

func (f fixtureQueryService) UserShow(string) (UserInspection, error) {
	var response UserInspection
	if err := f.decode("user_show_response", &response); err != nil {
		return UserInspection{}, err
	}
	return response, nil
}

func (f fixtureQueryService) ObjectsByPath(string) ([]CollectionObject, error) {
	var response struct {
		Objects []CollectionObject `json:"objects"`
	}
	if err := f.decode("objects_by_path_response", &response); err != nil {
		return nil, err
	}
	return response.Objects, nil
}

func (f fixtureQueryService) ObjectsByServer(string) ([]CollectionObject, error) {
	var response struct {
		Objects []CollectionObject `json:"objects"`
	}
	if err := f.decode("objects_by_server_response", &response); err != nil {
		return nil, err
	}
	return response.Objects, nil
}

func (f fixtureQueryService) CollectionShow(string) (CollectionInspection, error) {
	var response CollectionInspection
	if err := f.decode("collection_show_response", &response); err != nil {
		return CollectionInspection{}, err
	}
	return response, nil
}

func (f fixtureQueryService) CollectionGrants(string) ([]Access, error) {
	var response struct {
		Access []Access `json:"access"`
	}
	if err := f.decode("collection_access_response", &response); err != nil {
		return nil, err
	}
	return response.Access, nil
}

func (f fixtureQueryService) AuthzDiagnostic(string, string, string) (AuthzDiagnostic, error) {
	var response AuthzDiagnostic
	if err := f.decode("authzd_to_coll_response", &response); err != nil {
		return AuthzDiagnostic{}, err
	}
	return response, nil
}
