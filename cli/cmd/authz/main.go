package main

import (
	"fmt"
	"os"

	"client/internal/cli"
)

func main() {
	command := cli.NewRootCommand(cli.NewAPIClientFromConfig(), os.Stdout)
	if err := command.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
