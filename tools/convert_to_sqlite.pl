#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use JSON::MaybeXS qw< decode_json >;
use Path::Tiny qw< path >;

## no critic qw( ValuesAndExpressions::PreventSQLInjection );

local $| = 1;

my $dict_dir   = 'wordset-dictionary/data';
my %table_rows = (
    map +( $_ => [] ), qw<
        words meanings synonyms editors contributors
    >,
);

print "Reading files ... ";
my $count = 0;
path($dict_dir)->visit(sub {
    if ( $count > 1 ) {
        return;
    } else { $count++ }

    my $file = shift;

    $file->is_file && $file =~ /\.json$/xms
        or return;

    my $content = decode_json( $file->slurp );

    foreach my $word ( keys %{$content} ) {
        my $word_content = $content->{$word};
        my $wordset_id   = $word_content->{'wordset_id'};

        push @{ $table_rows{'words'} }, {
            'wordset_id' => $wordset_id,
            'word'       => $word_content->{'word'},
        };

        foreach my $meaning ( @{ $word_content->{'meanings'} } ) {
            push @{ $table_rows{'meanings'} }, {
                'meaning_id'  => $meaning->{'id'},
                'wordset_id'  => $wordset_id,
                'def'         => $meaning->{'def'},
                'speech_part' => $meaning->{'speech_part'},
            };

            foreach my $synonym ( @{ $meaning->{'synonyms'} } ) {
                push @{ $table_rows{'synonyms'} }, {
                    'wordset_id' => $wordset_id,
                    'name'       => $synonym,
                };
            }
        }

        foreach my $editor ( @{ $word_content->{'editors'} } ) {
            push @{ $table_rows{'editors'} }, {
                'wordset_id' => $wordset_id,
                'name'       => $editor,
            };
        }

        foreach my $contributor ( @{ $word_content->{'contributors'} } ) {
            push @{ $table_rows{'contributors'} }, {
                'wordset_id' => $wordset_id,
                'name'       => $contributor,
            };
        }
    }
}, { 'recurse' => 1 });

print "done\n";

print "Records: @{[ scalar @{ $table_rows{'words'} } ]}\n";

my $dbh = DBI->connect( 'dbi:SQLite:dbname=data/db.sqlite', '', '' );

print "Storing words in db ... ";
{
    my @word_records;
    foreach my $row ( @{ $table_rows{'words'} } ) {
        push @word_records, [ @{$row}{qw< wordset_id word >} ];
    }

    my $sth = $dbh->prepare('INSERT INTO words ( wordset_id, word ) VALUES (?,?)');
    $sth->execute( @{$_} ) for @word_records;
}
print "done\n";

print "Storing meanings in db ... ";
foreach my $row ( @{ $table_rows{'meanings'} } ) {
    my $example = $row->{'example'};
    my @cols
        = $example
        ? qw< id wordset_id def example speech_part >
        : qw< id wordset_id def speech_part >;

    my $cols_def   = join ',', @cols;
    my $values_def = join ',', map '?', @cols;

    my $sth = $dbh->prepare(
        "INSERT INTO meanings ($cols_def) VALUES ($values_def)",
    );

    my @values = map $row->{$_}, @cols;

    $sth->execute(@values);
}
print "done\n";

print "Storing synonyms in db ... ";
foreach my $row ( @{ $table_rows{'synonyms'} } ) {
    my $sth = $dbh->prepare(
        'INSERT INTO synonyms ( id, wordset_id, name ) '
      . 'VALUES (?,?,?)',
    );

    $sth->execute( @{$row}{qw< id wordset_id name >} );
}
print "done\n";

print "Storing editors in db ... ";
foreach my $row ( @{ $table_rows{'editors'} } ) {
    my $sth = $dbh->prepare(
        'INSERT INTO editors ( id, wordset_id, name ) '
      . 'VALUES (?,?,?)',
    );

    $sth->execute( @{$row}{qw< id wordset_id name >} );
}
print "done\n";

print "Storing contributors in db ... ";
foreach my $row ( @{ $table_rows{'contributors'} } ) {
    my $sth = $dbh->prepare(
        'INSERT INTO contributors ( id, wordset_id, name ) '
      . 'VALUES (?,?,?)',
    );

    $sth->execute( @{$row}{qw< id wordset_id name >} );
}
print "done\n";
