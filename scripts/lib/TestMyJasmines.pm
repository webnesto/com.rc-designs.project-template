#!/usr/bin/perl -w

#	***** BEGIN MIT LICENSE BLOCK *****
#
#	Copyright (c) 2011 B. Ernesto Johnson
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in
#	all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#	THE SOFTWARE.
#
#	***** END MIT LICENSE BLOCK *****

package TestMyJasmines;

#Includes
use strict;
use warnings;

use Cwd;
use Data::Dumper;
use File::Basename;
use File::Copy;
use File::Find;
use File::Path;
use File::Spec;
use FindBin qw( $Bin );
use IO::File;
use List::Util qw( first );
use Utils qw( printLog extend extendNew from_json_file emptyDirOfType );

#Variables

my $DEFAULT_CONFIG = "build.json";


#Functions

sub logStart {
	printLog(
		"++++++++++++++++"
	,	"Build The Tests!: "
	.	POSIX::strftime("%m/%d/%Y %H:%M:%S", localtime)
	.	"\n"
	);
}

sub logEnd {
	printLog(
		"The Tests are Built!: "
	.	POSIX::strftime("%m/%d/%Y %H:%M:%S", localtime)
	,	"++++++++++++++++"
	);
}

sub getConfig {
	my $execPath = Cwd::getcwd();
	my ( $path ) = @_;
	my $ret;

	if( File::Spec->file_name_is_absolute( $path ) ){
		$ret = $path;
	} else {
		$ret = File::Spec->catfile( $execPath, $path );
	}

	return $ret;
}

sub getConfigs {
	my $execPath = Cwd::getcwd();
	my $defaultConfig = from_json_file( File::Spec->catfile( $Bin, $DEFAULT_CONFIG ) );
	my $execConfig = from_json_file( File::Spec->catfile( $execPath, $DEFAULT_CONFIG ) );

	my @configs = (
		$defaultConfig
	,	$execConfig
	);

	my $argObj = {};
	foreach my $arg ( @_ ){
		if( $arg eq "-dev" ){	# Arguments override any config files
			$argObj->{ "build" } = "dev";
#		} elsif( $arg eq "-foo" ){
#			$argObj->{ "foo" } = "bar";
		} else {
			printLog("config file passed as arg: $arg" );
			push( @configs, from_json_file( getConfig( $arg ) ) );
		}
	}

	push( @configs, $argObj );

	return ( @configs );
}

sub getTests {
	my ( $location, $config ) = @_;
	my @tests = ();

	find(
		sub {
			my $file = $File::Find::name;
			my $relFile;
			if ( $file =~ /\.test\.js$/) {
				$relFile = File::Spec->abs2rel( $file, $location );
				printLog( "		test: $relFile" );
				push( @tests, $relFile )
			}
		}
	, 	$location
	);

	return @tests;
}

sub run {
	logStart();

	my $config = extendNew( getConfigs( @_ ) );
	my $location = Cwd::getcwd();
	my $scratch = $config->{ folders }->{ scratch };

	my @tests = getTests( $location, $config );

	printLog( "@tests !" );

	logEnd();
}

return 1;