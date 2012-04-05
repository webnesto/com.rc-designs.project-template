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

package BuildTheKraken;

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
my $REPLACE = "-CONTENT-";           # Used in replacement of dev build strings.
my $BUILD_DEV    = 'dev';
my $BUILD_PROD   = 'prod';
my $WARNING = 'GENERATED FILE - DO NOT EDIT';
my $MIN = "min";


#Functions

sub logStart {
	printLog(
		"++++++++++++++++"
	,	"Build The Kraken!: "
	.	POSIX::strftime("%m/%d/%Y %H:%M:%S", localtime)
	.	"\n"
	);
}

sub logEnd {
	my ( $build ) = @_;
	printLog(
		"The Kraken is Built!: "
	.	POSIX::strftime("%m/%d/%Y %H:%M:%S", localtime)
	.	" type:$build"
	,	"++++++++++++++++"
	);
}

sub printOrder ($) {
#	my $val = $_[0];
#	if( $val == 1 ) {
#		printLog( "B should come first\n" );
#		return;
#	}
#	if( $val == -1 ) {
#		printLog( "A should come first\n" );
#		return;
#	}
#	printLog( "Neither should come first, this is borken!\n" );
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

sub getFilenamesByType {
	my ( $location, $config, $filesForSourceCommands ) = @_;
	my $documentable;
	my $typeProps;
	my $targetedSource;
	my @filenames = ();
	my $extFiles = {};
	my $return = {};
	my $ext;
	my $numFiles;
	my @ignores;

	for my $filetype ( @{ $config->{ types } } ){
		$typeProps = $config->{ typeProps }->{ $filetype } or die "No properties for filetype: $filetype";
		$ext = $typeProps->{ extension } or die "No extension for filetype: $filetype";
		@ignores = ( @{ $config->{ ignores } }, @{ $typeProps->{ ignores } } );
		$filesForSourceCommands->{ $ext } = [];

		printLog( "processing $ext" );
		if( !defined( $return->{ $ext } ) ){
			$return->{ $ext } = {};
		}
		$extFiles = $return->{ $ext };

		if( $typeProps->{folder} ){
			$targetedSource = File::Spec->catdir( $location, $typeProps->{folder} );
		} else {
			$targetedSource = $location;
		}

		chdir $targetedSource;
		@filenames = glob "*";

		for my $folder (@filenames) {
			-d $folder or next;		# Only using folders.  Skipping files.
			if( indexOfPatternArray( \@ignores, $folder ) == -1 ){
				printLog( "	+ folder: $folder" );
				if ( !defined( $extFiles->{ $folder } ) ) {
					$extFiles->{ $folder } = ();
				}

				find(
					sub {
						my $file = $File::Find::name;
						my $relFile;
						if ( $file =~ /\.($ext)$/) {
							push( @{ $extFiles->{ $folder } }, $file );
							$relFile = File::Spec->abs2rel( $file, $targetedSource );
							push( @{ $filesForSourceCommands->{ $ext } }, $relFile );
							printLog( "		file: $_" );
						}
					}
				, 	File::Spec->catfile( $targetedSource, $folder )
				);

				if( !defined $extFiles->{ $folder } ){
					delete $extFiles->{ $folder };
				} else {
					$numFiles = @{ $extFiles->{ $folder } };
					printLog( "		TOTAL:$ext:$folder: $numFiles" );
				}

			} else {
				printLog( "	- ignore: $folder");
			}
		}
	}

	chdir $location; #get back to where we were

	return $return, $filesForSourceCommands;
}

sub parseProdContent {
	my ( $file, $argStates, $includedArgs, $location )  = @_;
	my @argStates = @{ $argStates };
	my @includedArgs = @{ $includedArgs };
	my $importPath;
	my $ret;

	if( -e $file ){
		my $fileIO = new IO::File( $file, "r" ) or die "could not open $file";
		while ( my $line = $fileIO->getline() ) {

			if ( $line =~ /\#build_import\s*([^\s]*)/ ) {
				$importPath = File::Spec->catfile( $location, $1 );
				$ret.= parseProdContent( $importPath, \@argStates, \@includedArgs, $location );
			} else {

				if(
					( $line =~ /\#endif/ )
				&&	( scalar( @argStates ) > 1 ) #ensure that there's an argState left to shift (protects against forgotten "endifs" left in files without openers)
				){
					shift( @argStates );
					next;
				}
				if ( $line =~ /\#ifdef\s*(\w+)/ ) {
					my $arg = $1;
					if ( Utils::indexOf( $arg, \@includedArgs ) > -1 && ( $argStates[0] ) ) {
						unshift( @argStates, 1 );
					} else {
						unshift( @argStates, 0 );
					}
				} #TODO: consider reversal of logic for ifndef directives.  What's their use in a JS build system?
				$ret.= $line if ( $argStates[0] );
			}

		}
		undef $fileIO;
	} else {
		die "does not exist for parsing. $file"
	}
	return $ret;
}

sub parseDevContent {
	my ( $file, $includeString, $sourceUrl, $location, $extension_out_dev ) = @_;
	my $tmpStr;
	my $importPath;
	my $import;
	my $recurse;
	my $ret;

	if( -e $file ){
		my $fileIO = new IO::File( $file, "r" ) or die "could not open $file";
		while ( my $line = $fileIO->getline() ) {

			if ( $line =~ /\#build_import\s*([^\s]*)/ ) {
				$import = "$sourceUrl$1";
				$import = replaceExtension( $import, $extension_out_dev );
				$tmpStr = $includeString;
				$tmpStr =~ s/$REPLACE/$import/;
				$importPath = File::Spec->catfile( $location, $import );
				printLog( "	dev - importing: $tmpStr" );
				$recurse = parseDevContent( $importPath, $includeString, $sourceUrl, $extension_out_dev );
				if( $recurse ){
					$ret.= $recurse;
				}
				$ret.= $tmpStr."\n";
			}

		}
		undef $fileIO;
	}
	return $ret;
}

sub replaceExtension{
	my ( $path, $ext ) = @_;
	if( $ext ){
		$path =~ s/(.*)\.[^\.]*$/$1.$ext/;
	}
	return $path;
}


sub getFolderToIndex {
	my ( $folders, $index ) = @_;
	my $return = join( "/", @{$folders}[0..( $index + 0 )] );
	#printLog( "getFolderToIndex:\n @{$folders} \n $index" );
	#printLog( "  return: $return \n" );
	return $return;
}

sub indexOfPatternArray{
	my ( $array, $target ) = @_;
	my @array = @{ $array };
	my $return = first {
		if ( $array[$_] =~ /^=~/ ){
			my $re = substr $array[$_], 2;
			return $target =~ $re;
		}
		elsif ( $array[$_] =~ /^!~/ ){
			my $re = substr $array[$_], 2;
			return $target !~ $re;
		}
		else {
			return $target eq $array[$_];
		}
	} 0 .. $#array;

	unless( defined $return ){
		$return = -1;
	}
#	printLog( "returning $return for $target" );
	return $return;
}

sub getBuildSorter {
	my ( $firsts, $lasts ) = @_;

	return sub {
		my $la = $a; # lc $a;
		my $lb = $b; #lc $b;

#		printLog( "\n$la\n$lb" );

		my @firsts = @{ $firsts };
		my @lasts = @{ $lasts };

		my @aDirs = split(/\\|\//, $la );
		my @bDirs = split(/\\|\//, $lb );

		my $aFolder = join( "/", @aDirs[0..(@aDirs - 2)] );
		my $bFolder = join( "/", @bDirs[0..(@bDirs - 2)] );

#		printLog( "a folder and b folder: \n   $aFolder\n   $bFolder\n " );

		my $aFirstIndex = -1;
		my $bFirstIndex = -1;
		my $aLastIndex = -1;
		my $bLastIndex = -1;

		if( @firsts > 0 ) {  # An array of "first" filenames/patterns has been provided... find the index of current sort files in array
			$aFirstIndex = indexOfPatternArray( $firsts, $aDirs[ $#aDirs ] );
			$bFirstIndex  = indexOfPatternArray( $firsts, $bDirs[ $#bDirs ] );
		}
		if( @lasts > 0 ) {	# An array of "last" filenames/patterns has been provided... find the index of current sort files in array
			$aLastIndex = indexOfPatternArray( $lasts, $aDirs[ $#aDirs ] );
			$bLastIndex = indexOfPatternArray( $lasts, $bDirs[ $#bDirs ] )
		}

		my $aIsAFirst = ( $aFirstIndex > -1 ) ? 1 : 0;
		my $bIsAFirst = ( $bFirstIndex > -1 ) ? 1 : 0;
		my $aIsALast = ( $aLastIndex > -1 ) ? 1 : 0;
		my $bIsALast = ( $bLastIndex > -1 ) ? 1 : 0;

		if( $aIsAFirst or $bIsAFirst ){ # If both are marked for first and are in the same directory, use the  passed array file sorting rules
			if(
				( $aIsAFirst and $bIsAFirst )
			and
				(	$aFolder eq $bFolder )
			) {
#				printLog( "both are marked for first and are in the same directory, use the  passed array file sorting rules." );
				printOrder( $aFirstIndex <=> $bFirstIndex );
				return $aFirstIndex <=> $bFirstIndex;
			}
			# If one has control file and a shorter path than the other, it should go first
			# If one has control file and a longer path than the other, it should go last
			if(
				$aIsAFirst
				&&(
					(
						( @aDirs < @bDirs )
						# and bDirs up 2 aDirs folder are identical
						&&( $aFolder eq getFolderToIndex( \@bDirs, @aDirs-2 ))
					)
					||
					( $aFolder eq $bFolder )
				)
			){
				printOrder( -1 );
				return -1
			}
			if(
				$bIsAFirst
				&&(
					(
						( @bDirs < @aDirs )
						&&( $bFolder eq getFolderToIndex( \@aDirs, @bDirs-2 ))
					)
					||
					( $aFolder eq $bFolder )
				)
			){
				printOrder(1);
				return 1;
			}
			#printLog( "a or b is a first, but no handling has been done: prob?\n\n." ); # This log is misleading, may happen even when there's no problem
		}

		if( $aIsALast or $bIsALast ){
			# If both are marked for first and are in the same directory, use the  passed array file sorting rules
			if(
				( $aIsALast and $bIsALast )
			and
				(	$aFolder eq $bFolder )
			) {
				printOrder( $aLastIndex <=> $bLastIndex );
				return $aLastIndex <=> $bLastIndex;
			}
			# If one has control file and a shorter path than the other, it should go last
			# If one has control file and a longer path than the other, it should go first
			if(
				$bIsALast
				&&(
					(
						( @bDirs < @aDirs )
						&&( $bFolder eq getFolderToIndex( \@aDirs, @bDirs-2 ))
					)
					||
					( $aFolder eq $bFolder )
				)
			) {
				printOrder( -1 );
				return -1
			}
			if(
				$aIsALast
				&&(
					(
						( @aDirs < @bDirs )
						&&( $aFolder eq getFolderToIndex( \@bDirs, @aDirs-2 ))
					)
					||
					( $aFolder eq $bFolder )
				)
			){
				printOrder( 1 );
				return 1;
			}
		}

		# else just do a normal evaluation
		my $ret = $la cmp $lb;
		printOrder( $ret );
		$la cmp $lb;
	}
}

sub makeFiles {
	my ( $config, $files, $location ) = @_;
	my $scratch = $config->{ folders }->{ scratch };
	my $folders_build = $config->{ folders }->{ build };
	my $root = $config->{ root };
	my $build = $config->{ build };
	my $sourceUrl = $config->{ dev }->{ url };
	my $keepers = $config->{ prod }->{ keep };
	my $type;
	my $ext;
	my $ext_out;
	my $ext_build;
	my $fileName;
	my $file;
	my $fromFile;
	my $typeProps;
	my $blockComment;
	my $buildSort;
	my $includeString;
	my $extension_out_dev;
	my $tmpFile;
	my $tmpStr;
	my $relPath;
	my $outputPath;
	my @argStates;
	my @fromFiles;


	if( File::Spec->file_name_is_absolute( $root ) ){
		$root = $root;
	} else {
		$root = File::Spec->catfile( $location, $root );
		$root = Cwd::realpath( $root );
	}

	foreach $type( keys %{ $files } ){
		$typeProps = $config->{ typeProps }->{ $type };
		$ext = $typeProps->{ extension };
		$ext_out = $typeProps->{ extension_out } ? $typeProps->{ extension_out } : $ext;
		$ext_build = ( $typeProps->{ build } ) ? $typeProps->{ build } : $ext;
		$extension_out_dev = $typeProps->{ extension_out_dev };
		$blockComment = $typeProps->{ block_comment };
		$blockComment =~ s/$REPLACE/$WARNING/;
		$includeString = $typeProps->{dev_include};
		$outputPath = File::Spec->catpath( $root, $ext_build, $folders_build );

		foreach $fileName ( keys %{ $files->{ $type } } ){
			$file = File::Spec->catfile( $scratch, "$fileName.$ext_out" );

			printLog( "making file: $file" );
			open FILE, ">$file" or die "Could not open $file\n";
			print FILE $blockComment."\n";
			print FILE $typeProps->{ prepend };

			@argStates = (1);

			$buildSort = getBuildSorter( $typeProps->{ firsts }, $typeProps->{ lasts } );

			@fromFiles = sort $buildSort @{ $files->{ $type }->{ $fileName } };
			foreach $fromFile ( @fromFiles ){
				printLog( "	adding $fromFile" );
				if ( $build eq $BUILD_PROD ) {
					$tmpFile = parseProdContent( $fromFile, \@argStates, $keepers, $location );
					print FILE $tmpFile if $tmpFile;
				} elsif ( $build eq $BUILD_DEV ) {
					my $tmpStr;
					my $arg;
					$tmpStr = parseDevContent( $fromFile, $includeString, $sourceUrl, $location , $extension_out_dev );
					if( $tmpStr ){
						print FILE $tmpStr;
					}

					# generate relative path

					$fromFile = Cwd::realpath( $fromFile );

					$relPath = File::Spec->abs2rel( $fromFile, $root ); #$fromFile; #

					#$relPath =~ s/\Q$location\U//;
					#$relPath =~ s/\\/\//g;
			#		printLog( "rel? $relPath" );
					$relPath = "$sourceUrl$relPath";    #remains relative as long as $sourceUrl has not been set
					$relPath = replaceExtension( $relPath, $extension_out_dev );
					$tmpStr = $includeString;

					$tmpStr =~ s/$REPLACE/$relPath/;
					printLog( "	dev - including: $tmpStr" );
					print FILE $tmpStr."\n";

				}

			}

			print FILE $typeProps->{ postpend };
			close FILE;
		}


	}
}

sub moveToTarget {
	my ( $config, $files, $location ) = @_;
	my $scratch = $config->{ folders }->{ scratch };
	my $bin = $config->{ folders }->{ build };
	my $build = $config->{ build };
	my $root = $config->{ root };
	my $doDeletes = $config->{ doDeletes };
	my $minPath;
	my $type;
	my $typeProps;
	my $buildFolder;
	my $ext;
	my $ext_out;
	my $fileName;
	my $file;
	my $minFile;
	my $finalFile;
	my $compressable;
	my @commands;
	my $command;

	if( File::Spec->file_name_is_absolute( $root ) ){
		$root = $root;
	} else {
		$root = File::Spec->catfile( $location, $root );
		$root = Cwd::realpath( $root );
	}


	$minPath = File::Spec->catdir( $scratch, $MIN );
	-e $minPath or mkdir $minPath or warn "Cannot make $minPath: $!";

	foreach $type( keys %{ $files } ){
		$typeProps = $config->{ typeProps }->{ $type };
		$ext = $typeProps->{ extension };
		$ext_out = $typeProps->{ extension_out } ? $typeProps->{ extension_out } : $ext;
		$buildFolder = $typeProps->{ build };
		if( $build eq $BUILD_PROD ){
			@commands = ( $typeProps->{ production_commands } ) ? @{ $typeProps->{ production_commands } } : ();
		} else {
			@commands = ( $typeProps->{ development_commands } ) ? @{ $typeProps->{ development_commands } } : ();
		}

		if( $buildFolder eq "" ){
			$buildFolder = File::Spec->catdir( $root, $ext );
			$buildFolder = File::Spec->catdir( $buildFolder, $bin );
		} else {
			$buildFolder = File::Spec->catdir( $root, $buildFolder );
		}

		-e $buildFolder or mkdir $buildFolder or warn "Cannot make $buildFolder";

		printLog( "	emptying $buildFolder of $ext_out files" );

		if( $doDeletes ){
			emptyDirOfType( $buildFolder, $ext_out );
		}

		foreach $fileName ( keys %{ $files->{ $type } } ){
			$file = File::Spec->catfile( $scratch, "$fileName.$ext_out" );
			$minFile = File::Spec->catfile( $scratch, $MIN, "$fileName.$ext_out" );
			if(
				( $build eq $BUILD_PROD )
			){
				copy( $file, $minFile ) or warn "Could not copy $file to $minFile: $!";
#				printLog( "running production commands on file: $file" );
				foreach $command ( @commands ){
					my $scriptPath = '{scriptsPath}';
					my $infile = '{infile}';
					my $outfile = '{outfile}';
					$command =~ s/$scriptPath/$Bin/g;
					$command =~ s/$infile/$minFile/g;
					$command =~ s/$outfile/$minFile/g;
					printLog( "trying $command" );
					`$command`;
				}
			} else {
				copy( $file, $minFile ) or warn "Could not copy $file to $minFile: $!";
			}

			$finalFile = File::Spec->catfile( $buildFolder, "$fileName.$ext_out" );
			copy( $minFile, $finalFile ) or warn "Could not copy $minFile, to $finalFile: $!";

			printLog("	created $finalFile" );
		}
	}
}

sub doSourceCommands {
	printLog( "beginning source commands" );
	my ( $config, $location, $filesForSourceCommands ) = @_;
	my $root = $config->{ root };
	my $typeProps;
	my $doCommands;
	my $build = $config->{ build } || $BUILD_PROD;
	my @files;
	my $ext;
	my @source_commands;
	my $command;
	my $filelist;

	my $scriptPath = '{scriptsPath}';
	my $filesVar = '{files}';
	my $rootVar = '{root}';


	if( File::Spec->file_name_is_absolute( $root ) ){
		$root = $root;
	} else {
		$root = File::Spec->catfile( $location, $root );
		$root = Cwd::realpath( $root );
	}

	for $ext ( keys %{ $filesForSourceCommands } ) {
		$typeProps = $config->{ typeProps }->{ $ext };
		@files = @{ $filesForSourceCommands->{ $ext } };
		$filelist = "@files";
		@source_commands = ( $typeProps->{ source_commands } ) ? @{ $typeProps->{ source_commands } } : ();
		$doCommands = $typeProps->{ do_source_commands } || "";
		if(
			$doCommands eq $build
		or	$doCommands eq "both"
		){
			$doCommands = 1;
		} else {
			$doCommands = 0;
		}
		if( $doCommands ){
			foreach $command ( @source_commands ){

				$command =~ s/$scriptPath/$Bin/g;
				$command =~ s/$filesVar/$filelist/g;
				$command =~ s/$rootVar/$root/g;
				printLog( "	trying: $command" );
				`$command`;
			}
		}
	}

	printLog( "ending source commands" );
}

sub doProdCommands {
	printLog( "beginning production commands" );
	my ( $config, $location ) = @_;
	my $typeProps;
	my $doCommands;
	my $build = $config->{ build } || $BUILD_PROD;
	my @commands;
	my $command;
	my $scriptPathVar = '{scriptsPath}';
	my $buildPathVar = '{buildPath}';

	if( $build ne $BUILD_PROD ){
		return 0;
	}

	@commands = ( $config->{ prod }->{ commands } ) ? @{ $config->{ prod }->{ commands } } : ();
	foreach $command ( @commands ){
		$command =~ s/$scriptPathVar/$Bin/g;
		$command =~ s/buildPathVar/$location/g;
		printLog( "	trying: $command" );
		`$command`;
	}

	printLog( "ending production commands" );
}

sub run {

	logStart();

	my $config = extendNew( getConfigs( @_ ) );
	my $build = $config->{ build } || $BUILD_PROD;
	my $location = Cwd::getcwd();
	my $scratch = $config->{ folders }->{ scratch };
	my $minPath;
	my $keepScratch = $config->{ keepScratch };

	#TODO: implement subs iteration - allow arguments for subs - default "current" directory.

	my ( $files, $filesForSourceCommands ) = getFilenamesByType( $location, $config, {} );
	-e $scratch or mkdir $scratch, 0777 or warn "Cannot make $scratch directory: $!";
	makeFiles( $config, $files, $location );
	moveToTarget( $config, $files, $location );

#	printLog( "Currently: ". Cwd::getcwd(). " old: $location" );
	if(
		( defined $scratch )
	&&	( !$keepScratch )
	){
		$scratch = File::Spec->catfile( $location, $scratch );
		$minPath = File::Spec->catdir( $scratch, $MIN );
		emptyDirOfType( $minPath, ".*" );
		rmdir $minPath or warn "Cannot delete $minPath";
		emptyDirOfType( $scratch, ".*" );
		rmdir $scratch or ( warn "Cannot delete $scratch" and my $err = 1 );
		if( !defined( $err ) ){
			printLog( "scratch directory deleted\n" );
		}
	}

	doSourceCommands( $config, $location, $filesForSourceCommands );

	logEnd( $build );
}

return 1;