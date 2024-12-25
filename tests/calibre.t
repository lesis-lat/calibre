#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use YAML::XS qw(Dump);
use FindBin qw($Bin);
use File::Spec;
use File::Path qw(remove_tree);
use IPC::Open3;
use Readonly;
use English qw(-no_match_vars);
use IO::Handle;

use lib '../lib';

our $VERSION = '1.0';

Readonly::Scalar my $EXIT_SHIFT => 8;
my $script_path = File::Spec->catdir($Bin, q{..}, q{calibre.pl});
my $temp_dir = tempdir(CLEANUP => 1);
local $ENV{PERL5LIB} = join(q{:}, File::Spec->catdir($Bin, q{..}, q{lib}), $ENV{PERL5LIB} || q{});

my $config = {
    organization => {
        name => 'TestOrg',
        accounts => [
            {
                name => 'Account1',
                status => 'active',
                code => 'TEST1',
            }
        ]
    }
};

my $config_file = File::Spec->catfile($temp_dir, 'test_config.yml');
YAML::XS::DumpFile($config_file, $config);

my $queries = {
    test => {
        description => 'test',
        query => 'SELECT 1'
    }
};
my $query_file = File::Spec->catfile($temp_dir, 'test_queries.yml');
YAML::XS::DumpFile($query_file, $queries);

{
    my ($writer, $reader, $error);
    my $pid = open3($writer, $reader, $error,
        $EXECUTABLE_NAME,
        "-I" . File::Spec->catdir($Bin, q{..}, q{lib}),
        $script_path
    );
    local $INPUT_RECORD_SEPARATOR = undef;
    my $output = <$reader>;
    waitpid($pid, 0);
    like($output, qr/Calibre Tool/sm, 'Shows help message when no arguments provided');
}

{
    if (-d 'reports') {
        remove_tree('reports');
    }

    my $cmd = qq{$EXECUTABLE_NAME -I${\File::Spec->catdir($Bin, q{..}, q{lib})} $script_path -i $query_file -r single -c $config_file};
    my $exit_code = system($cmd) >> $EXIT_SHIFT;
    is($exit_code, 0, 'Script exits with code 0 with valid arguments');

    if (-d 'reports') {
        remove_tree('reports');
    }
}

{
    my $invalid_config = {
        organization => {
            name => 'TestOrg',
            accounts => [
                {
                    name => 'Account1',
                    status => 'inactive',
                    code => 'TEST1',
                }
            ]
        }
    };

    my $invalid_config_file = File::Spec->catfile($temp_dir, 'invalid_config.yml');
    YAML::XS::DumpFile($invalid_config_file, $invalid_config);

    my ($writer, $reader, $error);
    my $pid = open3($writer, $reader, $error,
        $EXECUTABLE_NAME,
        "-I" . File::Spec->catdir($Bin, q{..}, q{lib}),
        $script_path,
        '-i', $query_file,
        '-r', 'single',
        '-c', $invalid_config_file
    );
    local $INPUT_RECORD_SEPARATOR = undef;
    my $output = <$reader>;
    waitpid($pid, 0);
    like($output, qr/No active accounts found/sm, 'Script dies when no active accounts are found');
}

done_testing();
