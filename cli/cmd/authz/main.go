package main

import (
	"fmt"
	"os"

	"client/internal/cli"
)

func main() {
	searcher, err := cli.NewFixtureInstitutionSearcher("testdata/institution_search_response.json")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	command := cli.NewRootCommand(searcher, os.Stdout)
	if err := command.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
