#!/usr/bin/perl
use strict;
use warnings;
use feature      qw< say >;
use experimental qw< postderef >;
use Dictionary::Wordset;

my $wordset = Dictionary::Wordset->new();
my $word    = $wordset->word('hello');

say "Word: ", $word->word;
say "  * Editors: ",      join ', ', $word->editors->@*;
say "  * Contributors: ", join ', ', $word->contributors->@*;
say "  * Meanings:";

foreach my $meaning ( $word->meanings->@* ) {
    say "    * Definition: ", $meaning->def;
    say "    * Speech part: ", $meaning->speech_part;
    say "    * Example: ", $meaning->example if $meaning->example;

    if ( $meaning->synonyms ) {
        say "    * Synonyms: ", join ', ', $meaning->synonyms->@*;
    }
}
