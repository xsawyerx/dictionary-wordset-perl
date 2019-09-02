package Dictionary::Wordset::Word::Meaning;
# ABSTRACT: Representing a single word meaning

use Moose;

has [ qw< id def speech_part > ] => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

has 'example' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

has 'synonyms' => (
    'is'  => 'ro',
    'isa' => 'ArrayRef[Str]',
);

no Moose;
__PACKAGE__->meta->make_immutable();

1;

__END__

=pod

=head1 DESCRIPTION

This module represents a single word meaning for a word from the Wordset
dictionary.

Instances of it are created when you use the main module,
L<Dictionary::Wordset>, which also contains the documentation.

=head1 METHODS

=head2 new(OPTIONS)

    my $word = Dictionary::Wordset::Word::Meaning->new(
        'id'          => '...',
        'wordset_id'  => '...',
        'def'         => '...',
        'speech_part' => '...',
        'example'     => '...',
        'synonyms'    => [...],
    );

You should not be creating a new one yourself. Use L<Dictionary::Wordset>
instead.

=head2 id

The ID of the meaning.

=head2 wordset_id

The Wordset ID of this meaning. This is a string.

=head2 def

The meaning definition. This is a string.

=head2 speech_part

The meaning speech part. This is a string.

=head2 example

An example for this meaning. This is a string.

=head2 synonyms

Synonyms for this meaning. This is an array reference.
