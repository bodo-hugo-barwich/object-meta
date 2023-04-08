#
# @author Bodo (Hugo) Barwich
# @version 2023-04-08
# @package Indexed List
# @subpackage Object/Meta.pm

# This Module defines Classes to manage Data in an indexed List
#
#---------------------------------
# Requirements:
# - The Perl Package "libconst-fast-perl" must be installed
#
#---------------------------------
# Features:
#

#==============================================================================
# The Object::Meta Package

=head1 NAME

Object::Meta - Library to manage data and meta data as one object but keeping it separate

=cut

package Object::Meta;

our $VERSION = '1.0.0';

#----------------------------------------------------------------------------
#Dependencies

use constant LIST_DATA      => 0;
use constant LIST_META_DATA => 1;

=head1 DESCRIPTION

C<Object::Meta> implements a Class to manage a data and additional meta data as an object

Of special importance it the B<Index Field> which is use to create an automatical index
in the C<Object::Meta::List>.

It does not require lengthly creation of definition modules.

=cut

#----------------------------------------------------------------------------
#Constructors

=head1 CONSTRUCTOR

=over 4

=item new ( [ INDEX_VALUE | DATA ] )

This is the constructor for a new C<Object::Meta> object.

C<INDEX_VALUE> - is a single scalar value for the B<Index Field> by which the object will be indexed.
This is only effective when the B<Index Field> is already configured.

C<DATA> - is passed in a hash like fashion, using key and value pairs.

=back

=cut

sub new {
    my $class = ref( $_[0] ) || $_[0];
    my $self  = undef;

    #Set the Default Attributes and assign the initial Values
    $self = [ {}, {} ];

    #Bestow Objecthood
    bless $self, $class;

    if ( scalar(@_) > 2 ) {

        #Parameters are a Key / Value List
        Object::Meta::set( $self, @_[ 1 .. $#_ ] );
    }
    else {
        #Parameter is a single Value
        Object::Meta::setIndexValue( $self, $_[1] );
    }

    #Give the Object back
    return $self;
}

sub DESTROY {
    my $self = $_[0];

    #Free the Lists
    $self->[LIST_DATA]      = ();
    $self->[LIST_META_DATA] = ();
}

#----------------------------------------------------------------------------
#Administration Methods

=head1 Administration Methods

=over 4

=item set ( DATA )

This Method will asign Values to B<physically Data Fields>.

C<DATA> is a list which is passed in a hash like fashion, using key and value pairs.

=back

=cut

sub set {

    #Take the Method Parameters
    my ( $self, %hshprms ) = @_;

    foreach ( keys %hshprms ) {

        #The Field Name must not be empty
        if ( $_ ne '' ) {
            $self->[LIST_DATA]{$_} = $hshprms{$_};
        }    #if($_ ne "")
    }    #foreach (keys %hshprms)
}

=pod

=over 4

=item setMeta ( DATA )

This Method will asign Values to B<Meta Data Fields>.

C<DATA> is a list which is passed in a hash like fashion, using key and value pairs.

=back

=cut

sub setMeta {

    #Take the Method Parameters
    my ( $self, %hshprms ) = @_;

    foreach ( keys %hshprms ) {

        #The Field Name must not be empty
        if ( $_ ne "" ) {
            $self->[LIST_META_DATA]{$_} = $hshprms{$_};
        }    #if($_ ne "")
    }    #foreach (keys %hshprms)
}

=pod

=over 4

=item setIndexField ( INDEX_FIELD )

This Method configure the B<Index Field> for this object.

C<INDEX_FIELD> - is the name of the Field which contains the Value by which the object
will be indexed.

=back

=cut

sub setIndexField {
    my ( $self, $sindexfield ) = @_;

    if ( defined $sindexfield ) {
        Object::Meta::setMeta( $self, 'indexfield', $sindexfield );
    }    #if(defined $sindexfield)

}

sub setIndexValue {
    my ( $self, $sindexvalue ) = @_;
    my $sindexfield = Object::Meta::getIndexField $self;

    if ( defined $sindexvalue
        && $sindexfield ne "" )
    {
        Object::Meta::set( $self, $sindexfield, $sindexvalue );
    }    #if(defined $sindexvalue && $sindexfield ne "")
}

sub Clear {
    my $self = $_[0];

    #Preserve Index Configuration
    my $sindexfield = Object::Meta::getIndexField $self;

    $self->[LIST_DATA]      = ();
    $self->[LIST_META_DATA] = ();

    #Restore Index Configuration
    Object::Meta::setIndexField $self, $sindexfield;
}

#----------------------------------------------------------------------------
#Consultation Methods

sub get {
    my ( $self, $sfieldname, $sdefault, $imta ) = @_;
    my $srs = $sdefault;

    unless ($imta) {
        if ( defined $sfieldname
            && $sfieldname ne "" )
        {
            if ( exists $self->[LIST_DATA]{$sfieldname} ) {
                $srs = $self->[LIST_DATA]{$sfieldname};
            }
            else {
                #Check as Meta Field
                $srs = Object::Meta::getMeta( $self, $sfieldname, $sdefault );
            }
        }    #if(defined $sfieldname && $sfieldname ne "")
    }
    else     #A Meta Field is requested
    {
        #Check a Meta Field
        $srs = Object::Meta::getMeta( $self, $sfieldname, $sdefault );
    }        #unless($imta)

    return $srs;
}

sub getMeta {
    my ( $self, $sfieldname, $sdefault ) = @_;
    my $srs = $sdefault;

    if ( defined $sfieldname
        && $sfieldname ne "" )
    {
        $srs = $self->[LIST_META_DATA]{$sfieldname}
          if ( exists $self->[LIST_META_DATA]{$sfieldname} );

    }    #if(defined $sfieldname && $sfieldname ne "")

    return $srs;
}

sub getIndexField {
    return Object::Meta::getMeta( $_[0], 'indexfield', '' );
}

sub getIndexValue {
    my $sindexfield = Object::Meta::getIndexField $_[0];

 #print "idx fld: '$sindexfield'; idx vl: '" . $_[0]->get($sindexfield) . "'\n";

    return Object::Meta::get( $_[0], $sindexfield );
}

return 1;
