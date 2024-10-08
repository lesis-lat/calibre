package Calibre::Engine::Steampipe {
    use strict;
    use warnings;
    use YAML::XS 'LoadFile';
    use Carp;

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

            my $output = '';
            open my $cmd, '-|', "steampipe query \"$query\" 2>&1" or croak "Failed to run steampipe query: $!";
            while (<$cmd>) {
                $output .= $_;
            }
            close $cmd or carp "Error running query '$query_name': $!";

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

                open my $fh, '>', $output_file or croak "Could not open file '$output_file' for writing: $!";
                print $fh "$query_name:\n";
                print $fh "  description: $description\n";
                print $fh "  output: |\n";
                $output =~ s/^/    /mgx;
                print $fh "$output\n";
                close $fh;

                push @generated_files, $output_file;
            }
            print "\nGenerated reports:\n", join("\n", @generated_files), "\n\n";
            return $self;
        }

        my $output_file = 'report.yml';
        open my $fh, '>', $output_file or croak "Could not open file '$output_file' for writing: $!";
        for my $query_name (keys %report) {
            print $fh "$query_name:\n";
            print $fh "  description: $report{$query_name}->{description}\n";
            print $fh "  output: |\n";
            my $output = $report{$query_name}->{output};
            $output =~ s/^/    /mgx;
            print $fh "$output\n";
        }
        close $fh;

        print "\nGenerated report:\n$output_file\n";

        return $self;
    }
}

1;
