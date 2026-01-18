#!/usr/bin/env perl

use 5.030;
use strict;
use warnings;
use lib 'lib';
use Calibre::Component::GetOps;
use Calibre::Network::Steampipe;
use Calibre::Utils::Helper;

our $VERSION = '0.0.1';

sub main {
    my $defaults = {
        report_type => 'single',
        config_file => 'config.yaml',
        input_file  => 'queries/aws/index.yml',
    };

    my $options = Calibre::Component::GetOps -> new() -> run($defaults);

    if (!$options -> {ok}) {
        print Calibre::Utils::Helper -> new();
        return 1;
    }

    Calibre::Network::Steampipe -> new() -> run(
        $options -> {input_file},
        $options -> {report_type},
        $options -> {config_file}
    );

    return 0;
}

exit main();
