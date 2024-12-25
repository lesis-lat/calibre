#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::MockModule;
use File::Temp qw(tempdir);
use YAML::XS qw(Dump);
use File::Spec;
use File::Path qw(make_path remove_tree);
use Carp qw(croak);
use English qw(-no_match_vars);

use lib '../lib';

our $VERSION = '0.01';

sub cleanup_reports {
    if (-d 'reports') {
        remove_tree('reports');
    }
    return;
}

END {
    cleanup_reports();
}

use_ok('Calibre::Engine::Steampipe');

my $config = {
    organization => {
        name => 'TestOrg',
        accounts => [
            {
                name => 'Account1',
                status => 'active',
                code => 'TEST1',
            },
            {
                name => 'Account2',
                status => 'inactive',
                code => 'TEST2',
            }
        ]
    }
};

my $temp_dir = tempdir(CLEANUP => 1);
my $config_file = File::Spec->catfile($temp_dir, 'test_config.yml');
YAML::XS::DumpFile($config_file, $config);

my $queries = {
    test_query => {
        description => 'Test query description',
        query => 'SELECT 1;'
    }
};

my $query_file = File::Spec->catfile($temp_dir, 'test_queries.yml');
YAML::XS::DumpFile($query_file, $queries);

my $mock = Test::MockModule->new('Calibre::Engine::Steampipe');
$mock->mock('open', sub {
    my ($self, $mode, $cmd) = @_;
    if ($cmd =~ m/steampipe query/sm) {
        open my $fh, '<', \qq{test output\n}
            or croak sprintf('Cannot open mock filehandle: %s', $ERRNO);
        local $INPUT_RECORD_SEPARATOR = undef;
        my $output = <$fh>;
        close $fh or croak sprintf('Failed to close filehandle: %s', $ERRNO);

        open my $return_fh, '<', \$output
            or croak sprintf('Cannot create return filehandle: %s', $ERRNO);
        return $return_fh;
    }
    return CORE::open($self, $mode, $cmd);
});

{
    cleanup_reports();

    lives_ok(
        sub {
            Calibre::Engine::Steampipe->new($query_file, 'single', $config_file);
        },
        'Creates single report without dying'
    );

    ok(
        -d 'reports/TestOrg',
        'Organization directory created'
    );

    ok(
        -f 'reports/TestOrg/Account1-report.yml',
        'Single report file created for active account'
    );

    cleanup_reports();
}

{
    cleanup_reports();

    lives_ok(
        sub {
            Calibre::Engine::Steampipe->new($query_file, 'multiple', $config_file);
        },
        'Creates multiple reports without dying'
    );

    ok(
        -d 'reports/TestOrg/Account1',
        'Account directory created for multiple reports'
    );

    ok(
        -f 'reports/TestOrg/Account1/test_query-report.yml',
        'Multiple report file created for active account'
    );

    cleanup_reports();
}

done_testing();
