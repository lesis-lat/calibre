#!/usr/bin/env perl

use 5.030;
use strict;
use warnings;
use lib 'lib';
use Calibre::Engine::Steampipe;
use Calibre::Utils::Helper;
use Getopt::Long;
use YAML::XS 'LoadFile';

our $VERSION = '0.0.1';

sub main {
    my $report_type = 'single';
    my $config_file = 'config.yaml';
    my $input_file  = 'queries/aws/index.yml';

    my $options_ok = Getopt::Long::GetOptions(
        "i|input=s"  => \$input_file,
        "r|report=s" => \$report_type,
        "c|config=s" => \$config_file
    );

    if (!$options_ok || !$input_file || !$config_file) {
        print Calibre::Utils::Helper -> new();

        return 1;
    }


    my $configuration = LoadFile($config_file);
    my @accounts = grep { $_ -> {status} && $_ -> {status} eq 'active' } @{$configuration -> {organization} -> {accounts}};

    if (!@accounts) {
        die "No active accounts found in configuration file.\n";
    }

    Calibre::Engine::Steampipe -> new($input_file, $report_type, $config_file);

    return 0;
}

exit main();
