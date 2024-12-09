package Calibre::Utils::Helper{

    use strict;
    use warnings;

    our $VERSION = '0.01';

    sub new {
        return <<"EOT";

Calibre Tool v0.0.1
Core Commands
==============
Command                 Description
-------                 -----------
-i, --input             Input file with queries in YAML format
-r, --report            Report type:
                        - 's' or 'single' for a single report of all queries
                        - 'm' or 'multiple' for individual reports for each query

EOT
        }
}

1;
