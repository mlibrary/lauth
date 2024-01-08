#!/usr/bin/perl

# This file comes from the httpd:2.4 image. It is inlined here without
# modifications other than removing the warning comments and adding the
# shebang, so it can be used with the built image or standalone server.

# It is reproduced under license: https://www.apache.org/licenses/LICENSE-2.0

##
##  printenv -- demo CGI program which just prints its environment
##
use strict;
use warnings;

print "Content-type: text/plain; charset=iso-8859-1\n\n";
foreach my $var (sort(keys(%ENV))) {
    my $val = $ENV{$var};
    $val =~ s|\n|\\n|g;
    $val =~ s|"|\\"|g;
    print "${var}=\"${val}\"\n";
}
