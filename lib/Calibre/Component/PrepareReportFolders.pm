package Calibre::Component::PrepareReportFolders {
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
        my ($self, $organization_name) = @_;
        make_path('reports');
        my $organization_folder = File::Spec -> catdir('reports', $organization_name);
        make_path($organization_folder);
        return $organization_folder;
    }
}

1;
