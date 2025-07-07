requires "Getopt::Long", "2.54";
requires "Mojo::JSON", "9.41";        
requires "Mojo::UserAgent", "9.41";  
requires "YAML::XS", "0.69";
requires "Carp", "1.52";
requires "English", "1.11";

on 'test' => sub {
    requires "Test::More", "1.302206";
    requires "Test::Exception", "0.43";
    requires "Test::MockModule", "0.179.0";
    requires "File::Temp", "0.2311";
    requires "File::Spec", "3.80";
    requires "File::Path", "2.18";
    requires "IPC::Open3", "1.21";
    requires "Readonly", "2.05";
    requires "IO::Handle", "1.46";
};
