#!/usr/bin/env perl

use strict;
use warnings;

use lib 'blib/lib';

use Test::More;

use Geo::OSM::Overpass;
use Geo::OSM::Overpass::Plugin::ElementInfo;
use Geo::BoundingBox;

my $num_tests = 0;

my $element_type = 'node';
my $element_id = '3290997140';

my $eng = Geo::OSM::Overpass->new();
ok(defined $eng && 'Geo::OSM::Overpass' eq ref $eng, 'Geo::OSM::Overpass->new()'.": called") or BAIL_OUT('Geo::OSM::Overpass->new()'.": failed, can not continue."); $num_tests++;
$eng->verbosity(2);

my $plug = Geo::OSM::Overpass::Plugin::ElementInfo->new({
	'engine' => $eng
});
ok(defined($plug) && 'Geo::OSM::Overpass::Plugin::ElementInfo' eq ref $plug, 'Geo::OSM::Overpass::Plugin::ElementInfo->new()'." : called"); $num_tests++;

ok(defined $plug->gorun(
	$element_id,
	$element_type
), "checking gorun()"); $num_tests++;

## FIXME
my $result = $eng->last_query_result();
ok(defined($result), "checking last_query_result() got result back."); $num_tests++;
# saturn operator, see https://perlmonks.org/?node_id=11100099
ok(defined($result) && 1 == (()=$$result=~m|<$element_type.+?id="|gs), "checking result contains exactly one node."); $num_tests++;
ok(defined($result) && 1 == $$result =~ m|<${element_type}.+?id="${element_id}"|gs, "checking result contains specified node."); $num_tests++;

# END
done_testing($num_tests);
