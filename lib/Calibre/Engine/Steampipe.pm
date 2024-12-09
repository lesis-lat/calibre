package Calibre::Engine::Steampipe {
    use strict;
    use warnings;
    use YAML::XS 'LoadFile';
    use Carp;
    use English qw(-no_match_vars);

    our $VERSION = '0.01';

    sub new {
        my ($class, $input_file, $report_type) = @_;
        my $self = bless {}, $class;

        my $queries = LoadFile($input_file);
        my %report;

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

        if ($report_type eq 'multiple') {
            my @generated_files;
            for my $query_name (keys %report) {
                my $description = $report{$query_name}->{description};
                my $output = $report{$query_name}->{output};
                my $output_file = "$query_name-report.yml";
                my $file_error;

                {
                    open my $fh, '>', $output_file
                        or do { $file_error = $ERRNO; croak "Could not open file '$output_file' for writing: $file_error" };
                    print $fh "$query_name:\n";
                    print $fh "  description: $description\n";
                    print $fh "  output: |\n";
                    $output =~ s/^/    /mgxs;
                    print $fh "$output\n";
                    close $fh or carp "Error closing file '$output_file': $ERRNO";
                }

                push @generated_files, $output_file;
            }
            print "\nGenerated reports:\n", join("\n", @generated_files), "\n\n";
            return $self;
        }

        my $output_file = 'report.yml';
        my $file_error;

        {
            open my $fh, '>', $output_file
                or do { $file_error = $ERRNO; croak "Could not open file '$output_file' for writing: $file_error" };
            for my $query_name (keys %report) {
                print $fh "$query_name:\n";
                print $fh "  description: $report{$query_name}->{description}\n";
                print $fh "  output: |\n";
                my $output = $report{$query_name}->{output};
                $output =~ s/^/    /mgxs;
                print $fh "$output\n";
            }

            close $fh or carp "Error closing file '$output_file': $ERRNO";
        }

        print "\nGenerated report:\n$output_file\n";
        return $self;
    }
}
1;
