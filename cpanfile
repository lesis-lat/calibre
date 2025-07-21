requires "Getopt::Long",            "2.58";
requires "Mojo::JSON",              "9.41";        
requires "Mojo::UserAgent",         "9.41";  
requires "YAML::XS",                "0.904.0";
requires "Carp",                    "1.52";
requires "English",                 "5.42.0";

on 'test' => sub {
    requires "Test::More",          "1.302214";
    requires "Test::Exception",     "0.43";
    requires "Test::MockModule",    "0.180.0";
    requires "File::Temp",          "0.2311";
    requires "File::Spec",          "3.80";
    requires "File::Path",          "2.18";
    requires "IPC::Open3",          "5.42.0";
    requires "Readonly",            "2.05";
    requires "IO::Handle",          "1.55";
};
