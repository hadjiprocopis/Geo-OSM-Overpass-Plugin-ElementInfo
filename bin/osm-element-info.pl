#!/usr/bin/env perl

use strict;
use warnings;

use utf8;
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

use Getopt::Long;
use File::Spec;

use Geo::OSM::Overpass;
use Geo::OSM::Overpass::Plugin::ElementInfo;

my $outfile = undef;

my $VERBOSITY = 0;

my $engine = Geo::OSM::Overpass->new();
if( ! defined $engine ){ print STDERR "$0 : call to ".'Geo::OSM::Overpass->new()'." has failed.\n"; exit(1) }

my $element_id = undef;
my $element_type = undef;

if( ! Getopt::Long::GetOptions(
	'outfile=s' => sub {
		$engine->output_filename($_[1]);
		$outfile = $_[1];
	},
	'element-id=s' => \$element_id,
	'element-type=s' => \$element_type,
	'timeout=i' => sub { $engine->query_timeout($_[1]) },
	'maxsize=i' => sub { $engine->max_memory_size($_[1]) },
	'output-type=s' => sub { $engine->query_output_type($_[1]) },
	'verbosity=i' => sub {
		$engine->verbosity($_[1]);
		$VERBOSITY = $_[1];
	},
) ){ print STDERR usage($0) . "\n$0 : something wrong with command line parameters.\n"; exit(1); }

if( ! defined $element_id ){ print STDERR usage($0) . "\n$0 : an element id must be specified using --element-id\n"; exit(1) }
if( ! defined $element_type ){ print STDERR usage($0) . "\n$0 : an element type must be specified using --element-type\n"; exit(1) }

#if( ! defined $outfile ){ print STDERR usage($0) . "\n$0 : an output file must be specified using --outfile.\n"; exit(1); }

$engine->verbosity($VERBOSITY);


my $plug = Geo::OSM::Overpass::Plugin::ElementInfo->new({
	'engine' => $engine
});
if( ! defined $plug ){ print STDERR "$0 : call to ".'Geo::OSM::Overpass::Plugin::ElementInfo->new()'." has failed.\n"; exit(1) }

if( ! defined $plug->gorun(
	$element_id,
	$element_type
) ){ print STDERR "$0 : call to ".'gorun()'." has failed for element id '$element_id', of type '$element_type'.\n"; exit(1) }

if( defined $outfile ){
	$engine->output_filename($outfile);
	if( ! $engine->save() ){ print STDERR "$0 : failed to save output to file '$outfile'.\n"; exit(1) }
	print "$0 : success, output written to '$outfile'.\n";
} else {
	print "$0 : success, output dumped below:\n";
	print ${$engine->last_query_result()}."\n";
}
exit(0);

sub	usage {
	print "Usage : $0 <options>\noptions:\n"
	. "--element-id id : specify an OSM element id.\n"
	. "--element-type type : specify an OSM element type, e.g. 'node' or 'way' or 'relation'.\n"
	. "[--outfile OUTFILE.xml : where output goes.]\n"
	. "[--verbosity N : be verbose if N > 0.]\n"
	. "[--timeout T : seconds before the query times out, default is ".$engine->query_timeout()." seconds.]\n"
	. "[--output-type T : output type, default is ".$engine->query_output_type().".]\n"
	. "[--max-num-items M : maximum number of items to get, default is ".(defined($engine->query_output_type())?$engine->query_output_type():'unlimited').".]\n"
	. "\nProgram by Andreas Hadjiprocopis (c) 2019\n\n"
}
