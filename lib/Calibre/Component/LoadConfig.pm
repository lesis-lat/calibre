package Calibre::Component::LoadConfig {
    use strict;
    use warnings;
    use YAML::XS 'LoadFile';

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $config_file) = @_;
        return LoadFile($config_file);
    }
}

1;
