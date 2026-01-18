package Calibre::Component::GetOps {
    use strict;
    use warnings;
    use Getopt::Long;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $defaults) = @_;
        my %options = %{$defaults};
        my $options_ok = Getopt::Long::GetOptions(
            'i|input=s'  => \$options{input_file},
            'r|report=s' => \$options{report_type},
            'c|config=s' => \$options{config_file}
        );

        my $ok = 1;
        if (!$options_ok) {
            $ok = 0;
        }
        if (!$options{input_file}) {
            $ok = 0;
        }
        if (!$options{config_file}) {
            $ok = 0;
        }

        return {
            ok          => $ok,
            input_file  => $options{input_file},
            report_type => $options{report_type},
            config_file => $options{config_file},
        };
    }
}

1;
