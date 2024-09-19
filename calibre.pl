#!/usr/bin/env perl

use 5.030;
use strict;
use warnings;
use lib "./lib/";
use Calibre::Engine::Steampipe;
use Calibre::Utils::Helper;
use Getopt::Long;

sub main {
    my ($input_file, $report_type);

    Getopt::Long::GetOptions(
        "i|input=s"  => \$input_file,
        "r|report=s" => \$report_type,
    );

    if (!$input_file || !$report_type) {
        print Calibre::Utils::Helper->new();
        return 1;
    }

    my %report_actions = (
        's|single'   => sub { Calibre::Engine::Steampipe->new($input_file) },
        'm|multiple' => sub { Calibre::Engine::Steampipe->new($input_file, 'multiple') },
    );

    my $action = (grep { $report_type =~ /$_/x } keys %report_actions)[0];
    if ($action) {
        $report_actions{$action}->();
        return 0;
    }
}

exit main();
