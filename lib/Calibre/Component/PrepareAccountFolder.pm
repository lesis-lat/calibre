package Calibre::Component::PrepareAccountFolder {
    use strict;
    use warnings;
    use File::Path qw(make_path);
    use File::Spec;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $organization_folder, $account_name) = @_;
        my $account_folder = File::Spec -> catdir($organization_folder, $account_name);
        make_path($account_folder);
        return $account_folder;
    }
}

1;
