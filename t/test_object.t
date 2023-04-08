#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2023-04-08
# @package Test for the Object::Meta Module
# @subpackage test_object.t

# This Module runs tests on the Object::Meta Module
#
#---------------------------------
# Requirements:
# - The Perl Module "Object::Meta" must be installed
#



use warnings;
use strict;

use Cwd qw(abs_path);

use Time::HiRes qw(gettimeofday);

use Test::More;

BEGIN
{
  use lib "lib";
  use lib "../lib";
}  #BEGIN

require_ok('Object::Meta');

use Object::Meta;



my $smodule = "";
my $spath = abs_path($0);


($smodule = $spath) =~ s/.*\/([^\/]+)$/$1/;
$spath =~ s/^(.*\/)$smodule$/$1/;

#Disable Warning Message Translation
$ENV{'LANGUAGE'} = 'C';


my $obj = undef;
my %objdata = ('field1' => 'value1', 'field2' => 'value2', 'field3' => 'value3');

subtest 'Constructors' => sub {

	#------------------------
	#Test: 'Constructors'

  subtest 'empty object' => sub {
	  $obj = Object::Meta->new(%objdata);

	  is(ref $obj, 'Object::Meta', "object 'Object::Meta': created correctly");

    is( $obj->get('field1', ''), '', "Field 'field1': does not exist as expected" );
  };
  subtest 'object from data' => sub {
	  $obj = Object::Meta->new(%objdata);

	  is(ref $obj, 'Object::Meta', "object 'Object::Meta': created correctly");

	  foreach (keys %objdata) {
	    is( $obj->get($_, ''), $objdata{$_}, "Field '$_': added correctly" );
	  }
  };
};



done_testing();

