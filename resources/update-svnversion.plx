#!/usr/bin/perl -w

use strict;

while (<>) {
    print;
    last if m#<key>CFBundleVersion#;
}

$_ = <>;

if ($_) {
    # Change it
    my $version = `svnversion ..`;
    chomp $version;
    s#<string>VERSION</string>#<string>$version</string>#;

    # Print it out
    print;
}

while (<>) { print; }
