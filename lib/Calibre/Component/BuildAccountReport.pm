package Calibre::Component::BuildAccountReport {
    use strict;
    use warnings;

    use Calibre::Component::RunQuery;
    use Calibre::Component::ResolveRegion;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        my $self = bless {
            run_query      => Calibre::Component::RunQuery -> new(),
            resolve_region => Calibre::Component::ResolveRegion -> new(),
        }, $class;

        return $self;
    }

    sub run {
        my ($self, $account, $queries) = @_;
        my $account_name = $account -> {name};
        my $access_key = $account -> {access_key};
        my $secret_key = $account -> {secret_key};
        my $region = $self -> {resolve_region} -> run($account);

        local $ENV{AWS_ACCESS_KEY_ID} = $access_key;
        local $ENV{AWS_SECRET_ACCESS_KEY} = $secret_key;
        local $ENV{AWS_DEFAULT_REGION} = $region;

        my %report;
        for my $query_name (keys %{$queries}) {
            my $description = $queries -> {$query_name} -> {description};
            my $query = $queries -> {$query_name} -> {query};

            my $output = $self -> {run_query} -> run($query, $account_name);

            $report{$query_name} = {
                description => $description,
                output      => $output,
            };
        }

        return \%report;
    }
}

1;
