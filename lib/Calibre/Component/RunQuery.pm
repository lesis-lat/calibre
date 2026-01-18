package Calibre::Component::RunQuery {
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
        my ($self, $query, $account_name) = @_;
        my $output = q{};
        my $command_error;

        open my $command_handle, q{-|}, qq{steampipe query "$query" 2>&1}
            or do {
                $command_error = $ERRNO;
                croak "Failed to run steampipe query for $account_name: $command_error";
            };

        while (<$command_handle>) {
            $output .= $_;
        }

        if (!close $command_handle) {
            $command_error = $ERRNO;
            carp "Error running query for $account_name: $command_error";
        }

        return $output;
    }
}

1;
