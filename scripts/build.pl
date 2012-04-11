#!/usr/bin/perl
use FindBin qw($Bin);
use lib "$FindBin::Bin/lib";

use BuildTheKraken;

BuildTheKraken::run( @ARGV );