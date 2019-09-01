package Dictionary::Wordset::Word;
# ABSTRACT: Representing a single word from Wordset

use Moose;
use Dictionary::Wordset::Word::Meaning;
use Ref::Util qw< is_hashref >;

## no critic qw( Subroutines::RequireArgUnpacking )
sub BUILDARGS {
    my $class = shift;

    my %args = @_ == 1 && is_hashref( $_[0] ) ? %{ $_[0] } : @_;

    # FIXME: Might be bug in data
    foreach my $meaning ( @{ $args{'meanings'} } ) {
        if ( $meaning->{'synonyms'} ) {
            $meaning->{'synonyms'} = [ map defined, @{ $meaning->{'synonyms'} } ];
        }
    }

    $args{'meanings'} = [
        map Dictionary::Wordset::Word::Meaning->new($_),
        @{ $args{'meanings'} },
    ];

    return \%args;
}

has 'word' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

has 'wordset_id' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

has 'meanings' => (
    'is'       => 'ro',
    'isa'      => 'ArrayRef',
    'required' => 1,
);

has [ qw< editors contributors > ] => (
    'is'      => 'ro',
    'isa'     => 'ArrayRef',
    'default' => sub { [] },
);

no Moose;
__PACKAGE__->meta->make_immutable();

1;

__END__

=pod
