package Calibre::Component::EnsureActiveAccounts {
    use strict;
    use warnings;
    use Carp;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $active_accounts) = @_;
        if (!@{$active_accounts}) {
            croak 'No active accounts found in configuration.';
        }

        return $active_accounts;
    }
}

1;
