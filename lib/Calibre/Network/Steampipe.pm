package Calibre::Network::Steampipe {
    use strict;
    use warnings;

    use Calibre::Component::LoadQueries;
    use Calibre::Component::LoadConfig;
    use Calibre::Component::FilterActiveAccounts;
    use Calibre::Component::EnsureActiveAccounts;
    use Calibre::Component::PrepareReportFolders;
    use Calibre::Component::PrepareAccountFolder;
    use Calibre::Component::BuildAccountReport;
    use Calibre::Component::BuildMultipleReportContent;
    use Calibre::Component::BuildSingleReportContent;
    use Calibre::Component::WriteFile;

    our $VERSION = '0.0.1';

    sub new {
        my ($class) = @_;
        my $self = bless {
            load_queries            => Calibre::Component::LoadQueries -> new(),
            load_config             => Calibre::Component::LoadConfig -> new(),
            filter_active_accounts  => Calibre::Component::FilterActiveAccounts -> new(),
            ensure_active_accounts  => Calibre::Component::EnsureActiveAccounts -> new(),
            prepare_report_folders  => Calibre::Component::PrepareReportFolders -> new(),
            prepare_account_folder  => Calibre::Component::PrepareAccountFolder -> new(),
            build_account_report    => Calibre::Component::BuildAccountReport -> new(),
            build_multiple_report   => Calibre::Component::BuildMultipleReportContent -> new(),
            build_single_report     => Calibre::Component::BuildSingleReportContent -> new(),
            write_file              => Calibre::Component::WriteFile -> new(),
        }, $class;

        return $self;
    }

    sub run {
        my ($self, $input_file, $report_type, $config_file) = @_;
        my $queries = $self -> {load_queries} -> run($input_file);
        my $configuration = $self -> {load_config} -> run($config_file);
        my $organization_name = $configuration -> {organization} -> {name};
        my $accounts = $configuration -> {organization} -> {accounts};
        my $active_accounts = $self -> {filter_active_accounts} -> run($accounts);
        $self -> {ensure_active_accounts} -> run($active_accounts);

        my $organization_folder = $self -> {prepare_report_folders} -> run($organization_name);
        my $account_reports = $self -> _collect_account_reports($active_accounts, $queries);

        if ($report_type eq 'multiple') {
            $self -> _write_multiple_reports($organization_folder, $organization_name, $account_reports);
            print "\nGenerated multiple reports for each account.\n";
            return 1;
        }

        $self -> _write_single_reports($organization_folder, $organization_name, $account_reports);
        print "\nGenerated single report for each account.\n";
        return 1;
    }

    sub _collect_account_reports {
        my ($self, $active_accounts, $queries) = @_;
        my %account_reports;

        for my $account (@{$active_accounts}) {
            my $account_name = $account -> {name};
            print "\nProcessing account: $account_name\n";
            my $report = $self -> {build_account_report} -> run($account, $queries);
            $account_reports{$account_name} = $report;
        }

        return \%account_reports;
    }

    sub _write_multiple_reports {
        my ($self, $organization_folder, $organization_name, $account_reports) = @_;

        for my $account_name (keys %{$account_reports}) {
            my $account_folder = $self -> {prepare_account_folder} -> run($organization_folder, $account_name);

            for my $query_name (keys %{$account_reports -> {$account_name}}) {
                my $output_file = "$account_folder/$query_name-report.yml";
                my $description = $account_reports -> {$account_name} -> {$query_name} -> {description};
                my $output = $account_reports -> {$account_name} -> {$query_name} -> {output};

                my $content = $self -> {build_multiple_report} -> run(
                    $organization_name,
                    $account_name,
                    $query_name,
                    $description,
                    $output
                );

                $self -> {write_file} -> run($output_file, $content);
            }
        }

        return 1;
    }

    sub _write_single_reports {
        my ($self, $organization_folder, $organization_name, $account_reports) = @_;

        for my $account_name (keys %{$account_reports}) {
            my $output_file = "$organization_folder/$account_name-report.yml";
            my $content = $self -> {build_single_report} -> run(
                $organization_name,
                $account_name,
                $account_reports -> {$account_name}
            );

            $self -> {write_file} -> run($output_file, $content);
        }

        return 1;
    }
}

1;
