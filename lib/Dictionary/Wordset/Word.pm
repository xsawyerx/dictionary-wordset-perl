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
    #        where synonyms are available, but undef()
    # So this removes any undef() entries
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

=head1 DESCRIPTION

This module represents a single word from the Wordset dictionary.

Instances of it are created when you use the main module,
L<Dictionary::Wordset>, which also contains the documentation.

=head1 METHODS

=head2 new(OPTIONS)

    my $word = Dictionary::Wordset::Word->new(
        'word'         => 'foo',
        'wordset_id'   => 'b4caff442',
        'meanings'     => [
            {
                'id'          => '...',
                'wordset_id'  => 'b4caff442',
                'def'         => '...',
                'speech_part' => '...',
                'example'     => '...',
                'synonyms'    => [...],
            },

            ...
        ],

        'editors'      => [ 'foo', 'bar' ],
        'contributors' => [ 'baz' ],
    );

You should not be creating a new one yourself. Use L<Dictionary::Wordset>
instead.

=head2 word

The actual word string.

=head2 wordset_id

The Wordset ID of this word. This is a string.

=head2 meanings

    use feature      qw< say >;
    use experimental qw< postderef >;

    foreach my $meaning ( $word->meanings->@* ) {
        say "ID: ",          $meaning->id;
        say "Definition: ",  $meaning->def;
        say "Speech part: ", $meaning->speech_part;
        say "Example: ",     $meaning->example;
        say "Synonyms: ", join ', ', $meaning->synonyms->@*;
    }

The meanings for this word. These is an array of
L<Dictionary::Wordset::Word::Meaning> objects.

=head2 editors

The editors for the word. These are strings, not objects.

=head2 contributors

The contributors for the word. These are strings, not objects.
