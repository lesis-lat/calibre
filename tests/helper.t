#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib '../lib';

our $VERSION = '0.01';

use_ok('Calibre::Utils::Helper');

my $helper = Calibre::Utils::Helper->new();

like(
    $helper,
    qr/Calibre Tool/sm,
    'Helper output contains tool name'
);

like(
    $helper,
    qr/-i,[ ]--input/smx,
    'Helper output contains input option'
);

like(
    $helper,
    qr/-r,[ ]--report/smx,
    'Helper output contains report option'
);

done_testing();
