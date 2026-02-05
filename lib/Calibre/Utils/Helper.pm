package Calibre::Utils::Helper {
    use strict;
    use warnings;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        my @lines = (
            'Calibre Tool v0.0.1',
            'Core Commands',
            '==============',
            'Command                 Description',
            '-------                 -----------',
            '-i, --input             Input file with queries in YAML format',
            '-r, --report            Report type:',
            "                        - 's' or 'single' for a single report",
            '                          of all queries',
            "                        - 'm' or 'multiple' for individual",
            '                          reports for each query',
            '-c, --config            Configuration file with data in YAML format',
        );

        return join "\n", @lines;
    }
}

1;
