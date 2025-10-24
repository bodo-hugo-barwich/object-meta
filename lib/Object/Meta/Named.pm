# @author Bodo (Hugo) Barwich
# @version 2025-10-24
# @package Indexed List by Name
# @subpackage classes_metanames.pm

# This Module defines Classes to manage Data indexed in a List by its Name
#
#---------------------------------
# Requirements:
# - The Perl Package "perl-Digest-MD5" must be installed
# - The Perl Package "perl-Data-Dump" must be installed
#
#---------------------------------
# Features:
#

#==============================================================================
# The Object::Meta::Named Package

=head1 NAME

Object::Meta::Named - Library to recognise a special C<Name> field from the raw data

=cut

package Object::Meta::Named;

#----------------------------------------------------------------------------
#Dependencies

use parent 'Object::Meta';

use Digest::MD5 qw(md5_hex);

=head1 DESCRIPTION

C<Object::Meta::Named> implements a class which adds a C<name> field to the raw data which
can be used to index the C<Object::Meta> entries.

Additionally a C<hash> meta data field will be created for indexation and lookup.

The C<hash> meta data field becomes the index field.

=cut

#----------------------------------------------------------------------------
#Constructors

=head1 METHODS

=head2 Constructor

=head3 new ( [ DATA ] )

This is the constructor for a new C<Object::Meta::Named> object.
It creates a new object from B<raw data> which is passed in a hash key / value pairs.

B<Parameters:>

=over 4

=item C<DATA>

The B<raw data> which is passed in a hash key / value pairs.

If a C<name> field is present it will be used to index the entry.

=back

=cut

sub new {
    my $class = ref( $_[0] ) || $_[0];
    my $self  = undef;

    #Take the Method Parameters
    my %hshprms = @_[ 1 .. $#_ ];

    $self = $class->SUPER::new(%hshprms);

    #Set the Primary Index Field
    Object::Meta::setIndexField( $self, 'hash' );

    if ( defined $hshprms{'name'} ) {
        Object::Meta::Named::setName( $self, $hshprms{'name'} );
    }
    else {
        Object::Meta::Named::setName $self;
    }

    #Give the Object back
    return $self;
}

#----------------------------------------------------------------------------
#Administration Methods

=head3 setName ( [ NAME ] )

This will create a C<name> field in the raw data and index the object by the hash of it.

B<Parameters:>

=over 4

=item C<NAME>

The string value for the name of the object.

If a C<NAME> is empty is undefined it will empty the C<name> field and
the C<hash> meta data field.

=back

=cut

sub setName {
    my $self = $_[0];

    if ( scalar(@_) > 1 ) {
        Object::Meta::set( $self, 'name', $_[1] );
    }
    else {
        Object::Meta::set( $self, 'name', '' );
    }

    if ( $self->[Object::Meta::LIST_DATA]{'name'} ne '' ) {
        Object::Meta::set( $self, 'hash',
            md5_hex( $self->[Object::Meta::LIST_DATA]{'name'} ) );
    }
    else {
        Object::Meta::set( $self, 'hash', '' );
    }
}

#----------------------------------------------------------------------------
#Consultation Methods

=head3 getName ()

Returns the content of the C<name> field.

=cut

sub getName {
    return $_[0]->[Object::Meta::LIST_DATA]{'name'};
}

return 1;
