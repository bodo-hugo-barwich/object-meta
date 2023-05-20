#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2023-05-20
# @package Test for the Object::Meta Module
# @subpackage test_object.t

# This Module runs tests on the Object::Meta::List Module
#
#---------------------------------
# Requirements:
# - The Perl Module "Object::Meta::Liist" must be installed
#



use warnings;
use strict;

use Cwd qw(abs_path);

use Test::More;

BEGIN
{
  use lib "lib";
  use lib "../lib";
}  #BEGIN

require_ok('Object::Meta::List');

use Object::Meta::List;



my $smodule = "";
my $spath = abs_path($0);


($smodule = $spath) =~ s/.*\/([^\/]+)$/$1/;
$spath =~ s/^(.*\/)$smodule$/$1/;


my $list = undef;
my $obj = undef;
my %obj1data = ('field1' => 'value1', 'field2' => 'value2', 'field3' => 'value3');
my %obj2data = ('field1' => 'value4', 'field2' => 'value5', 'field3' => 'value6');
my %obj3data = ('field1' => 'value7', 'field2' => 'value8', 'field3' => 'value9');
my %obj1meta = ('indexfield' => 'field1', 'updated' => 'new');
my %obj2meta = ('indexfield' => 'field1', 'updated' => 'new');
my %obj3meta = ('indexfield' => 'field1', 'updated' => 'new');

subtest 'Constructor' => sub {

  #------------------------
  #Test: 'Constructor'

  subtest 'empty list' => sub {
    $list = Object::Meta::List->new();

    is(ref $list, 'Object::Meta::List', "List 'Object::Meta::List': created correctly");

    is( $list->getMetaObjectCount(), 0, "List is empty as expected" );
    is( $list->getMetaObject(0), undef, "Object with Index '0': does not exist as expected" );
  };
};

subtest 'Add Objects' => sub {

  #------------------------
  #Test: 'Constructor'

  subtest 'Add Objects as Hash' => sub {
    $list = Object::Meta::List->new();

    is(ref $list, 'Object::Meta::List', "List 'Object::Meta::List': created correctly");

    is( $list->getMetaObjectCount(), 0, "List is empty as expected" );
    is( $list->getMetaObject(0), undef, "Object with Index '0': does not exist as expected" );

    $list->Add(%obj1data);
    $list->Add(%obj2data);
    $list->Add(%obj3data);

    is( $list->getMetaObjectCount(), 3, "List has 3 Objects" );

    $obj = $list->getMetaObject(0);

    isnt( $obj, undef, "Object with Index '0': is set" );
    is( ref $obj, 'Object::Meta', "Object with Index '0': is an 'Object::Meta'" );
  };
  subtest 'Add Objects as Object::Meta' => sub {
    $list = Object::Meta::List->new();

    is(ref $list, 'Object::Meta::List', "List 'Object::Meta::List': created correctly");

    is( $list->getMetaObjectCount(), 0, "List is empty as expected" );
    is( $list->getMetaObject(0), undef, "Object with Index '0': does not exist as expected" );

    $obj = Object::Meta->new(%obj1data);

    $obj->setMeta(%obj1meta);

    $list->Add($obj);

    $obj = Object::Meta->new(%obj2data);

    $obj->setMeta(%obj2meta);

    $list->Add($obj);

    $obj = Object::Meta->new(%obj3data);

    $obj->setMeta(%obj3meta);

    $list->Add($obj);

    is( $list->getMetaObjectCount(), 3, "List has 3 Objects" );

    $obj = $list->getMetaObject(0);

    isnt( $obj, undef, "Object with Index '0': is set" );
    is( ref $obj, 'Object::Meta', "Object with Index '0': is an 'Object::Meta'" );
  };
  subtest 'Add Objects by the ID Value' => sub {
    $list = Object::Meta::List->new();

    is(ref $list, 'Object::Meta::List', "List 'Object::Meta::List': created correctly");

    is( $list->getMetaObjectCount(), 0, "List is empty as expected" );
    is( $list->getMetaObject(0), undef, "Object with Index '0': does not exist as expected" );

    # Create an Index with the setIndexField() method
    $list->setIndexField('field1');

    is( $list->getIndexField(), 'field1', "Index Field 'field1' as expected" );

    $list->Add('value1');
    $list->Add('value4');
    $list->Add('value7');

    is( $list->getMetaObjectCount(), 3, "List has 3 Objects" );
    is( $list->getIdxMetaObjectCount(), 3, "Indexed Objects: Count '3'" );

    $obj = $list->getMetaObject(0);

    isnt( $obj, undef, "Object with Index '0': is set" );
    is( ref $obj, 'Object::Meta', "Object with Index '0': is an 'Object::Meta'" );
  };
};

subtest 'Create Index' => sub {

  #------------------------
  #Test: 'Constructor'

  subtest 'primary index with set method' => sub {
    $list = Object::Meta::List->new();

    is(ref $list, 'Object::Meta::List', "List 'Object::Meta::List': created correctly");

    is( $list->getMetaObjectCount(), 0, "List is empty as expected" );
    is( $list->getMetaObject(0), undef, "Object with Index '0': does not exist as expected" );

	  # Create an Index by setting Field Name
	  $list->setIndexField('field1');

	  is( $list->getIndexField(), 'field1', "Index Field 'field1' as expected" );
  };
  subtest 'create index with create method' => sub {
    $list = Object::Meta::List->new();

    is(ref $list, 'Object::Meta::List', "List 'Object::Meta::List': created correctly");

    is( $list->getMetaObjectCount(), 0, "List is empty as expected" );
    is( $list->getMetaObject(0), undef, "Object with Index '0': does not exist as expected" );

    # Create an Index dirrectly with the createIndex() method
    $list->createIndex('indexname' => 'primary', 'checkfield' => 'field1');

    is( $list->getIndexField(), 'field1', "Index Field 'field1' as expected" );

    $list->Add(%obj1data);
    $list->Add(%obj2data);
    $list->Add(%obj3data);

    is( $list->getMetaObjectCount(), 3, "List has 3 Objects" );
    is( $list->getIdxMetaObjectCount(), 3, "Indexed Objects: Count '3'" );
  };
  subtest 'create index with fix value' => sub {
    $list = Object::Meta::List->new();

    is(ref $list, 'Object::Meta::List', "List 'Object::Meta::List': created correctly");

    is( $list->getMetaObjectCount(), 0, "List is empty as expected" );
    is( $list->getMetaObject(0), undef, "Object with Index '0': does not exist as expected" );

    # Create an Index with the setIndexField() method
    $list->setIndexField('field1');

    # Create an Index dirrectly with the createIndex() method
    $list->createIndex('indexname' => 'new', 'checkfield' => 'updated', 'checkvalue' => 'new', 'meta' => 1);

    # Primary Index was created automatically
    is( $list->getIndexField(), 'field1', "Index Field 'field1' as expected" );

    $obj = Object::Meta->new(%obj1data);

    $obj->setMeta(%obj1meta);

    $list->Add($obj);

    $obj = Object::Meta->new(%obj2data);

    $list->Add($obj);

    $obj = Object::Meta->new(%obj3data);

    $list->Add($obj);

    is( $list->getIdxMetaObjectCount(), 3, "Indexed Objects: Count '3'" );
    is( $list->getIdxMetaObjectCount('new'), 1, "Objects with Meta Field 'new': Count '1'" );
  };
};


done_testing();
