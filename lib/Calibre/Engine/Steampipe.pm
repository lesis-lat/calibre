package Calibre::Engine::Steampipe {
    use strict;
    use warnings;
    use YAML::XS 'LoadFile';
    use Carp;
    use English qw(-no_match_vars);
    use File::Basename qw(dirname);
    use File::Path qw(make_path);
    use File::Spec;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $input_file, $report_type, $config_file) = @_;
        my $self = bless {}, $class;

        my $queries = _load_queries($input_file);
        my $config  = LoadFile($config_file);
        my $organization_name = $config -> {organization} -> {name};
        my $accounts = $config -> {organization} -> {accounts};

        my @active_accounts = grep { $_ -> {status} eq 'active' } @{$accounts};

        if (!@active_accounts) {
            croak "No active accounts found in configuration.";
        }

        make_path('reports');
        my $org_folder = "reports/$organization_name";
        make_path($org_folder);

        my %account_reports;

        for my $account (@active_accounts) {
            my $account_name = $account -> {name};
            my $access_key = $account -> {access_key};
            my $secret_key = $account -> {secret_key};
            my $region = $account -> {details} -> {region} || 'us-east-1';

            print "\nProcessing account: $account_name\n";

            local $ENV{AWS_ACCESS_KEY_ID} = $access_key;
            local $ENV{AWS_SECRET_ACCESS_KEY} = $secret_key;
            local $ENV{AWS_DEFAULT_REGION} = $region;

            my %report;
            for my $query_name (keys %{$queries}) {
                my $description = $queries -> {$query_name} -> {description};
                my $query = $queries -> {$query_name} -> {query};

                print "Running query: $query_name for $account_name...\n";
                print "Description: $description\n";

                my $output = q{};
                my $cmd_error;

                open my $cmd, q{-|}, qq{steampipe query "$query" 2>&1}
                    or do { $cmd_error = $ERRNO; croak "Failed to run steampipe query for $account_name: $cmd_error" };
                
                while (<$cmd>) {
                    $output .= $_;
                }

                if (!close $cmd) {
                    $cmd_error = $ERRNO;
                    carp "Error running query '$query_name' for $account_name: $cmd_error";
                }

                $report{$query_name} = {
                    description => $description,
                    output      => $output,
                };
            }

            $account_reports{$account_name} = \%report;
        }

        if ($report_type eq 'multiple') {
            for my $account_name (keys %account_reports) {
                my $account_folder = "$org_folder/$account_name";
                make_path($account_folder);

                for my $query_name (keys %{$account_reports{$account_name}}) {
                    my $output_file = "$account_folder/$query_name-report.yml";
                    my $file_error;

                    my $description = $account_reports{$account_name} -> {$query_name} -> {description};
                    my $output = $account_reports{$account_name} -> {$query_name} -> {output};
                    $output =~ s/^/      /mgxs;

                    my $content = "organization:\n" .
                        "  name: \"$organization_name\"\n" .
                        "  account:\n" .
                        "    - name: \"$account_name\"\n" .
                        "queries:\n" .
                        "  $query_name:\n" .
                        "    description: $description\n" .
                        "    output: |\n" .
                        "$output\n";

                    open my $fh, '>', $output_file or do { $file_error = $ERRNO; croak "Could not open file '$output_file' for writing: $file_error" };

                    print {$fh} $content or carp "Error writing file '$output_file': $ERRNO";

                    close $fh or carp "Error closing file '$output_file': $ERRNO";
                }
            }

            print "\nGenerated multiple reports for each account.\n";
            
            return $self;
        } 

        for my $account_name (keys %account_reports) {
            my $output_file = "$org_folder/$account_name-report.yml";
            my $file_error;

            my $content = "organization:\n" .
                "  name: \"$organization_name\"\n" .
                "  account:\n" .
                "    - name: \"$account_name\"\n" .
                "queries:\n";

            for my $query_name (keys %{$account_reports{$account_name}}) {
                my $description = $account_reports{$account_name} -> {$query_name} -> {description};
                my $output = $account_reports{$account_name} -> {$query_name} -> {output};
                
                $output =~ s/^/      /mgxs;
                $content .= "  $query_name:\n" .
                    "    description: $description\n" .
                    "    output: |\n" .
                    "$output\n";
            }

            open my $fh, '>', $output_file or do { $file_error = $ERRNO; croak "Could not open file '$output_file' for writing: $file_error" };

            print {$fh} $content or carp "Error writing file '$output_file': $ERRNO";

            close $fh or carp "Error closing file '$output_file': $ERRNO";
        }
        
        print "\nGenerated single report for each account.\n";

        return $self;
    }

    sub _load_queries {
        my ($input_file) = @_;
        my $data = LoadFile($input_file);

        if (ref $data eq 'HASH' && exists $data -> {queries}) {
            my $query_groups = $data -> {queries};

            if (ref $query_groups ne 'HASH') {
                croak "Invalid query index format in '$input_file'.";
            }

            my %merged_queries;
            for my $category (sort keys %{$query_groups}) {
                my $files = $query_groups -> {$category};

                if (ref $files ne 'ARRAY') {
                    croak "Query category '$category' must be a list in '$input_file'.";
                }

                for my $file (@{$files}) {
                    my $resolved_file = _resolve_query_file($input_file, $file);
                    my $file_queries = LoadFile($resolved_file);

                    if (ref $file_queries ne 'HASH') {
                        croak "Query file '$resolved_file' must contain a YAML map.";
                    }

                    for my $query_name (keys %{$file_queries}) {
                        if (exists $merged_queries{$query_name}) {
                            croak "Duplicate query name '$query_name' found in '$resolved_file'.";
                        }

                        $merged_queries{$query_name} = $file_queries -> {$query_name};
                    }
                }
            }

            return \%merged_queries;
        }

        return $data;
    }

    sub _resolve_query_file {
        my ($input_file, $query_file) = @_;

        return $query_file if -e $query_file;

        my $base_dir = dirname($input_file);
        my $candidate = File::Spec -> catfile($base_dir, $query_file);
        return $candidate if -e $candidate;

        my $parent_dir = dirname($base_dir);
        $candidate = File::Spec -> catfile($parent_dir, $query_file);
        return $candidate if -e $candidate;

        croak "Query file '$query_file' referenced in '$input_file' was not found.";
    }
}

1;
