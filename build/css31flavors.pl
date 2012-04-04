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

#Includes
use FindBin qw($Bin);
use lib "$FindBin::Bin/lib";

use strict;
use warnings;

use File::Basename;
use File::Spec;
use POSIX;
use Utils qw( printLog );

printLog(
	"++++++++++++++++"
,	"begin css31flavors: "
.	POSIX::strftime("%m/%d/%Y %H:%M:%S", localtime)
);

# determine targetFolder
my $MAX = 31;

my $targetDir;
my @css_files;
my $css_file;
my @lines;
my @imports;
my $imports;
my $import;
my $line;
my $import_count;
my $file_count;
my $filename;
my $subfile;
my $tmpfile;

if (@ARGV){
	if( File::Spec->file_name_is_absolute( $ARGV[0] ) ){
		$targetDir = File::Spec->canonpath( $ARGV[0] );
		printLog( "css file path is absolute." );
	} else {
		$targetDir = File::Spec->catfile( getcwd, $ARGV[0] );
		printLog( "css file path is relative." );
	}
} else {
	$targetDir = getcwd;
}
printLog( "target directory is $targetDir" );

chdir $targetDir;
@css_files = glob "*.css";


sub startSubfile {
	my (
		$subfile
	,	$targetDir
	,	$filename
	,	$file_count
	) = @_;

	$subfile = File::Spec->catfile( $targetDir,  "$filename"."_"."$file_count.css" );
	printLog( "sub file: $subfile" );
	open FILEPART, ">$subfile";
	print TMPFILE "\@import \"$filename"."_"."$file_count.css\";\n";
}


foreach $css_file (@css_files) {

	my($filename, $directories, $suffix) = fileparse($css_file, qr/\Q.css\E/);

	printLog( "filename is: $filename" );

	open FILE, "<$css_file";
	@lines = <FILE>;
	@imports = ();

	foreach $line (@lines){
		if( $line =~ /^\@import.*/ ){
			push( @imports, $line );
		}
	}

	$imports = @imports;

	printLog( "has this many imports: $imports" );

	if( $imports > $MAX ){
		printLog( "creating subsets" );
		$import_count = 0;
		$file_count = 0;

		$tmpfile = File::Spec->catfile( $targetDir,  "$filename.tmp.css" );
		open TMPFILE, ">$tmpfile";

		&startSubfile(
			$subfile
		,	$targetDir
		,	$filename
		, $file_count
		);

		foreach $import  (@imports) {
			print FILEPART $import;
			$import_count = $import_count + 1;
			if( $import_count == $MAX ){
				close FILEPART;
				$file_count = $file_count + 1;
				&startSubfile(
					$subfile
				,	$targetDir
				,	$filename
				, $file_count
				);
			}
		}

		close FILEPART;
		close TMPFILE;
	} else {
		$tmpfile = 0;
	}


	close FILE;
	if( $tmpfile ){
		rename $tmpfile, $css_file;
	}
}

printLog(
	"end css31flavors:"
.	POSIX::strftime("%m/%d/%Y %H:%M:%S", localtime)
,	"++++++++++++++++"
);