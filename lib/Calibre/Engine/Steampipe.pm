package Calibre::Engine::Steampipe {
    use strict;
    use warnings;

    use Calibre::Network::Steampipe;

    our $VERSION = '0.0.1';

    sub new {
        my ($class, $input_file, $report_type, $config_file) = @_;
        Calibre::Network::Steampipe -> new() -> run($input_file, $report_type, $config_file);
        return bless {}, $class;
    }
}

1;
