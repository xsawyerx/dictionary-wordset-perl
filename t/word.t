#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'tests' => 8;
use Dictionary::Wordset::Word;

my $word = Dictionary::Wordset::Word->new(
    'word'       => 'unquestionably',
    'wordset_id' => 'b1f37f1814',
    'meanings'   => [
        {
            'id'          => 'befcd3e109',
            'def'         => 'without question and beyond doubt',
            'speech_part' => 'adverb',
            'synonyms'    => ['decidedly'],
        },

        {
            'id'      => 'a88d10fd8c',
            'def'     => 'without question',
            'example' => 'Fred Winter is unquestionably the jockey to follow',
            'speech_part' => 'adverb',
            'synonyms'    => [ 'unimpeachably', 'easily' ],
        },
    ],

    'contributors' => [ 'example1', 'example2' ],
);

isa_ok( $word, 'Dictionary::Wordset::Word' );
is( $word->word, 'unquestionably', 'Correct word' );
is( $word->wordset_id, 'b1f37f1814', 'Correct wordset ID' );

is_deeply(
    $word->editors,
    [],
    'No editors',
);

is_deeply(
    $word->contributors,
    [ 'example1', 'example2' ],
    'Correct contributors',
);

is(
    scalar @{ $word->meanings },
    2,
    'Got only 2 meanings',
);

isa_ok( $_, 'Dictionary::Wordset::Word::Meaning' )
    for @{ $word->meanings };
