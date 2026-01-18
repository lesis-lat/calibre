package Calibre::Component::ResolveRegion {
    use strict;
    use warnings;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $account) = @_;
        my $region = $account -> {details} -> {region};
        if (!$region) {
            $region = 'us-east-1';
        }

        return $region;
    }
}

1;
