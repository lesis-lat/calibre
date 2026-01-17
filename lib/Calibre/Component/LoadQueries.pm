package Calibre::Component::LoadQueries {
    use strict;
    use warnings;
    use YAML::XS 'LoadFile';
    use Carp;
    use File::Basename qw(dirname);
    use File::Spec;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $input_file) = @_;
        my $query_data = LoadFile($input_file);

        if (ref $query_data eq 'HASH' && exists $query_data -> {queries}) {
            my $query_groups = $query_data -> {queries};

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
                    my $resolved_file = $self -> _resolve_query_file($input_file, $file);
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

        return $query_data;
    }

    sub _resolve_query_file {
        my ($self, $input_file, $query_file) = @_;

        if (-e $query_file) {
            return $query_file;
        }

        my $base_dir = dirname($input_file);
        my $candidate = File::Spec -> catfile($base_dir, $query_file);
        if (-e $candidate) {
            return $candidate;
        }

        my $parent_dir = dirname($base_dir);
        $candidate = File::Spec -> catfile($parent_dir, $query_file);
        if (-e $candidate) {
            return $candidate;
        }

        croak "Query file '$query_file' referenced in '$input_file' was not found.";
    }
}

1;
