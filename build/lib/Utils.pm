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

package Utils;

#Includes
use strict;
use warnings;

use POSIX;
use JSON;

our @ISA = qw(Exporter);
our @EXPORT = qw(
	printLog
	extend
	extendNew
	from_json_file
	emptyDirOfType
);

# get index of item in array
sub indexOf {
	my ($item, $array) = @_;
	my @array = @{$array};
	my $l = scalar( @array );
	for( my $i = 0; $i < $l; $i++ ){
		if( $item eq $array[$i] ){
			return $i;
		}
	}
	return -1;
}

sub printLog {
#	print POSIX::strftime("%m/%d/%Y %H:%M:%S", localtime).":\n";
	foreach my $line ( @_ ){
		print "	".$line."\n";
	}
}

sub extend {
	my $baseObj = shift( @_ );
	my $obj;
	my $key;
	my $baseProp;
	my $prop;
	foreach $obj ( @_ ){
		foreach $key ( keys %{ $obj } ){
			$baseProp = $baseObj->{ $key };
			$prop = $obj->{ $key };
			if(
				( ref( $baseProp ) eq "HASH" )
			&&	( ref( $prop ) eq "HASH" )
			){
				extend( $baseProp, $prop );
			} else {
				$baseObj->{ $key } = $prop;
			}
		}
	}

	return $baseObj;
}

sub extendNew {
	my $base = {};

	foreach my $obj ( @_ ){
		extend( $base, $obj );
	}

	return $base;
}

#sub openConfigObj {
sub from_json_file {
	my ( $file ) = @_;
	my $json = "";

	if( -e $file ){
		printLog(
			"getting obj from JSON file: "
		.	$file
		);

		open CONFIG, "<$file";
		while (<CONFIG>) {
			chomp($_);
			s/(?<![":])\/\/.*(?!")$//;    # remove single line comments
			s/\"false\"/0/;               # don't bother with values set to "false"
			$json .= $_;
		}
		close CONFIG;

		return from_json $json;
	} else { # file doesn't exist, we'll return an empty object
		return {};
	}
}

sub emptyDirOfType {
	my ( $dir, $type ) = @_;
	my @files;

	if( ! -e $dir ){
		printLog( "Can't empty $dir: $!" );
		return 0;
	}

	@files = glob "$dir/*";

	for my $file ( @files ){
		if ( $file =~ /\.($type)$/) {
#			printLog( "deleting: $file" );
			unlink $file;
		}
	}


}



return 1;