package Calibre::Component::WriteFile {
    use strict;
    use warnings;
    use Carp;
    use English qw(-no_match_vars);

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $output_file, $content) = @_;
        my $file_error;

        open my $file_handle, '>', $output_file
            or do {
                $file_error = $ERRNO;
                croak "Could not open file '$output_file' for writing: $file_error";
            };

        print {$file_handle} $content or carp "Error writing file '$output_file': $ERRNO";

        close $file_handle or carp "Error closing file '$output_file': $ERRNO";

        return 1;
    }
}

1;
