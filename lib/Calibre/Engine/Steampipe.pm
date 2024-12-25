package Calibre::Engine::Steampipe {
    use strict;
    use warnings;
    use YAML::XS 'LoadFile';
    use Carp;
    use English qw(-no_match_vars);
    use File::Path qw(make_path);

    our $VERSION = '0.01';

    sub new {
        my ($class, $input_file, $report_type, $config_file) = @_;
        my $self = bless {}, $class;

        my $queries = LoadFile($input_file);
        my %report;

        my $config = LoadFile($config_file);
        my $organization_name = $config->{organization}->{name};
        my $accounts = $config->{organization}->{accounts};

        for my $query_name (keys %{$queries}) {
            my $description = $queries->{$query_name}->{description};
            my $query = $queries->{$query_name}->{query};

            print "\nRunning query: $query_name...\n";
            print "Description: $description\n";

            my $output = q{};
            my $cmd_error;

            open my $cmd, q{-|}, qq{steampipe query "$query" 2>&1}
                or do { $cmd_error = $ERRNO; croak "Failed to run steampipe query: $cmd_error" };
            while (<$cmd>) {
                $output .= $_;
            }
            if (!close $cmd) {
                $cmd_error = $ERRNO;
                carp "Error running query '$query_name': $cmd_error";
            }

            $report{$query_name} = {
                description => $description,
                output      => $output,
            };
        }

        make_path('reports');

        my $org_folder = "reports/$organization_name";
        make_path($org_folder);

        my @active_accounts = grep { $_->{status} eq 'active' } @{$accounts};

        if ($report_type eq 'multiple') {
            for my $account (@active_accounts) {
                my $account_name = $account->{name};
                my $account_folder = "$org_folder/$account_name";
                make_path($account_folder);

                for my $query_name (keys %report) {
                    my $output_file = "$account_folder/$query_name-report.yml";
                    my $file_error;

                    open my $fh, '>', $output_file
                        or do { $file_error = $ERRNO; croak "Could not open file '$output_file' for writing: $file_error" };

                    print $fh "organization:\n";
                    print $fh "  name: \"$organization_name\"\n";
                    print $fh "  account:\n";
                    print $fh "    - name: \"$account_name\"\n";

                    print $fh "queries:\n";
                    print $fh "  $query_name:\n";
                    print $fh "    description: $report{$query_name}->{description}\n";
                    print $fh "    output: |\n";
                    my $output = $report{$query_name}->{output};
                    $output =~ s/^/      /mgxs;
                    print $fh "$output\n";

                    close $fh or carp "Error closing file '$output_file': $ERRNO";
                }
            }
            print "\nGenerated multiple reports for each account.\n";
            return $self;
        }

        for my $account (@active_accounts) {
            my $account_name = $account->{name};
            my $output_file = "$org_folder/$account_name-report.yml";
            my $file_error;

            open my $fh, '>', $output_file
                or do { $file_error = $ERRNO; croak "Could not open file '$output_file' for writing: $file_error" };

            print $fh "organization:\n";
            print $fh "  name: \"$organization_name\"\n";
            print $fh "  account:\n";
            print $fh "    - name: \"$account_name\"\n";

            print $fh "queries:\n";
            for my $query_name (keys %report) {
                print $fh "  $query_name:\n";
                print $fh "    description: $report{$query_name}->{description}\n";
                print $fh "    output: |\n";
                my $output = $report{$query_name}->{output};
                $output =~ s/^/      /mgxs;
                print $fh "$output\n";
            }

            close $fh or carp "Error closing file '$output_file': $ERRNO";
        }
        print "\nGenerated single report for each account.\n";

        return $self;
    }
}

1;
