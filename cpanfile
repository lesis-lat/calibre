requires "Getopt::Long",            "2.58";
requires "Mojo::JSON", "9.46";
requires "Mojo::UserAgent", "9.46";
requires "YAML::XS", "v0.908.0";
requires "Carp",                    "1.52";
requires "English",                 "5.42.0";

on 'test' => sub {
    requires "Test::More", "1.302220";
    requires "Test::Exception",     "0.43";
    requires "Test::MockModule", "v0.185.3";
    requires "File::Temp", "0.2312";
    requires "File::Spec",          "3.80";
    requires "File::Path",          "2.18";
    requires "IPC::Open3",          "5.42.0";
    requires "Readonly",            "2.05";
    requires "IO::Handle",          "1.55";
};