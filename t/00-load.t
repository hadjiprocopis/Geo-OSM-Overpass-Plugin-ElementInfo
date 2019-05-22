#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Geo::OSM::Overpass::Plugin::ElementInfo' ) || print "Bail out!\n";
}

diag( "Testing Geo::OSM::Overpass::Plugin::ElementInfo $Geo::OSM::Overpass::Plugin::ElementInfo::VERSION, Perl $], $^X" );
