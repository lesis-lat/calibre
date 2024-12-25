requires "Getopt::Long", "2.54";
requires "Mojo::JSON";
requires "Mojo::UserAgent";
requires "YAML::XS";
requires "Carp";
requires "English";

on 'test' => sub {
    requires "Test::More";
    requires "Test::Exception";
    requires "Test::MockModule";
    requires "File::Temp";
    requires "File::Spec";
    requires "File::Path";
    requires "Find::Bin";
    requires "IPC::Open3";
    requires "Readonly";
    requires "IO::Handle";
};
