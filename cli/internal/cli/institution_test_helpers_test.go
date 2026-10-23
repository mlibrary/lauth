package cli

type fakeInstitutionSearcher struct {
	pattern      string
	institutions []Institution
}

func (f *fakeInstitutionSearcher) SearchInstitutions(pattern string) ([]Institution, error) {
	f.pattern = pattern
	return f.institutions, nil
}
