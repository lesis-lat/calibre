package Calibre::Component::BuildMultipleReportContent {
    use strict;
    use warnings;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $organization_name, $account_name, $query_name, $description, $output) = @_;
        my $formatted_output = $output;
        $formatted_output =~ s/^/      /mgxs;

        return "organization:\n" .
            "  name: \"$organization_name\"\n" .
            "  account:\n" .
            "    - name: \"$account_name\"\n" .
            "queries:\n" .
            "  $query_name:\n" .
            "    description: $description\n" .
            "    output: |\n" .
            "$formatted_output\n";
    }
}

1;
