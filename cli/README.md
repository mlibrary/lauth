# lauth-cli - Library Authorization CLI

A command-line interface (CLI) for managing data in the Library Authorization
system.

## Tools used for implementation:

 - [> gli](http://davetron5000.github.io/gli/) - Git Like Interface is the easy way to make command-suite CLI apps.
 - [ROM](https://rom-rb.org/) - Ruby Object Mapper is an open-source persistence and mapping toolkit for Ruby built for speed and simplicity.

## Configuration File

The configuration file essentially stores command line option values to use as defaults when not specified by the user. The command `initconfig` that will create an initial version of the configuration file.

```shell
./bin/lauth --url http://localhost:9292 --username=lauth --password=lauth initconfig
```
The file `.lauth.rc` will be located in the user's home directory based on the value of the HOME environment variable. The next time you run `./bin/lauth`, the values for --url, --password, and --username will be defaulted to the values you specified when you ran `initconfig`. Of course, you can edit this file to make changes; it's just a simple YAML file.

[RDoc](lauth.rdoc)
