#!/usr/bin/env perl

use 5.030;
use strict;
use warnings;
use lib "./lib/";
use Calibre::Engine::Steampipe;
use Calibre::Utils::Helper;
use Getopt::Long;
use YAML::XS 'LoadFile';

our $VERSION = '0.01';

sub main {
    my ($input_file, $report_type, $config_file);
    Getopt::Long::GetOptions(
        "i|input=s"  => \$input_file,
        "r|report=s" => \$report_type,
        "c|config=s" => \$config_file,
    );

    if (!$input_file || !$report_type || !$config_file) {
        print Calibre::Utils::Helper->new();
        return 1;
    }

    # load organization and active accounts
    my $data = LoadFile($config_file);
    my @accounts = grep { $_->{status} && $_->{status} eq 'active' }
                       @{$data->{organization}->{accounts}};

    if (!@accounts) {
        die "No active accounts found in configuration file.\n";
    }

    Calibre::Engine::Steampipe->new($input_file, $report_type, $config_file);

    return 0;
}

exit main();
