package Calibre::Component::FilterActiveAccounts {
    use strict;
    use warnings;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $accounts) = @_;
        my @active_accounts = grep { $_ -> {status} && $_ -> {status} eq 'active' } @{$accounts};
        return \@active_accounts;
    }
}

1;
