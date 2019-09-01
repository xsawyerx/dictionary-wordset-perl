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
