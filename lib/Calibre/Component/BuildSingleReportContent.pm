package Calibre::Component::BuildSingleReportContent {
    use strict;
    use warnings;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        return bless {}, $class;
    }

    sub run {
        my ($self, $organization_name, $account_name, $account_reports) = @_;
        my $content = "organization:\n" .
            "  name: \"$organization_name\"\n" .
            "  account:\n" .
            "    - name: \"$account_name\"\n" .
            "queries:\n";

        for my $query_name (keys %{$account_reports}) {
            my $description = $account_reports -> {$query_name} -> {description};
            my $output = $account_reports -> {$query_name} -> {output};
            my $formatted_output = $output;
            $formatted_output =~ s/^/      /mgxs;

            $content .= "  $query_name:\n" .
                "    description: $description\n" .
                "    output: |\n" .
                "$formatted_output\n";
        }

        return $content;
    }
}

1;
