package Dictionary::Wordset;
# ABSTRACT: Perl interface to Wordset

use DBI;
use Moose;
use Path::Tiny ();
use File::ShareDir ();
use Dictionary::Wordset::Word;

## no critic qw( ValuesAndExpressions::ProhibitMagicNumbers )

has 'db_file' => (
    'is'      => 'ro',
    'isa'     => 'Str',
    'default' => sub {
        return path(
            File::ShareDir::dist_dir('Dictionary-Wordset'),
            'db.sqlite',
        )->stringify;
    },
);

has 'dbh' => (
    'is'      => 'ro',
    'isa'     => 'Object',
    'lazy'    => 1,
    'builder' => '_build_dbh',
);

sub _build_dbh {
    my $self = shift;
    my $file = $self->db_file;
    my $dbh  = DBI->connect( "dbi:SQLite:dbname=$file", '', '' );
    return $dbh;
}

sub word {
    my ( $self, $word_str ) = @_;

    my $wordset_id = $self->_get_wordset_id($word_str);
    my %extra_args;

    my $meanings_rows = $self->_get_meanings($wordset_id);
    if ( @{$meanings_rows} ) {
        $extra_args{'meanings'} = [
            map +{
                'id'          => $_->[0],
                'def'         => $_->[1],
              ( 'example'     => $_->[2] )x!!$_->[2],
                'speech_part' => $_->[3],
            },
            @{$meanings_rows},
        ];
    }

    my $synonyms = $self->_get_synonyms($wordset_id);
    if ( @{$synonyms} ) {
        $extra_args{'synonyms'} = $synonyms;
    }

    my $editors = $self->_get_editors($wordset_id);
    if ( @{$editors} ) {
        $extra_args{'editors'} = [ map @{$_}, @{$editors} ];
    }

    my $contributors = $self->_get_contributors($wordset_id);
    if ( @{$contributors} ) {
        $extra_args{'contributors'} = [ map @{$_}, @{$contributors} ];
    }

    my $word = Dictionary::Wordset::Word->new(
        'wordset_id' => $wordset_id,
        'word'       => $word_str,
        %extra_args,
    );

    return $word;
}

sub _get_wordset_id {
    my ( $self, $word_str ) = @_;

    my $sth = $self->dbh->prepare('SELECT wordset_id FROM words WHERE word = ?');
    $sth->execute($word_str);
    my $word_row = $sth->fetchrow_arrayref();

    return $word_row->[0];
}

sub _get_meanings {
    my ( $self, $wordset_id ) = @_;

    my $sth = $self->dbh->prepare('SELECT id, def, example, speech_part FROM meanings WHERE wordset_id = ?');
    $sth->execute($wordset_id);
    my $meanings_rows = $sth->fetchall_arrayref();

    return $meanings_rows;
}

sub _get_synonyms {
    my ( $self, $wordset_id ) = @_;

    my $sth = $self->dbh->prepare('SELECT name FROM synonyms WHERE wordset_id = ?');
    $sth->execute($wordset_id);
    my $synonym_rows = $sth->fetchall_arrayref();

    return $synonym_rows;
}

sub _get_editors {
    my ( $self, $wordset_id ) = @_;

    my $sth = $self->dbh->prepare('SELECT name FROM editors WHERE wordset_id = ?');
    $sth->execute($wordset_id);
    my $editor_rows = $sth->fetchall_arrayref();

    return $editor_rows;
}

sub _get_contributors {
    my ( $self, $wordset_id ) = @_;

    my $sth = $self->dbh->prepare('SELECT name FROM contributors WHERE wordset_id = ?');
    $sth->execute($wordset_id);
    my $contributor_rows = $sth->fetchall_arrayref();

    return $contributor_rows;
}

no Moose;
__PACKAGE__->meta->make_immutable();

1;

__END__

=pod

=head1 SYNOPSIS

    # This is for nicer syntax
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

=head1 DESCRIPTION

This module is an interface to the
L<Wordset word dictionary|https://github.com/wordset/wordset-dictionary>.

It embeds the entire dictionary as part of the distribution, so you don't
need to download it separately.

There are scripts available to create a DB from the original data, and you
can manually use your copy if you wish.

=head1 DICTIONARY VERSION

This version is using the dicitonary version at commit
C<f3aa8aca6ecbebb5a3a906da83ed669cad8def35>.

=head1 METHODS

=head2 new(OPTIONS)

    my $wordset = Dictionary::Wordset->new(...);

    my $wordset = Dictionary::Wordset->new(
        'db_file' => $path_to_sqlite_db_file,
    );

    my $wordset = Dictionary::Wordset->new(
        'dbh' => $db_object_from_DBI
    );

Create a new Wordset object.

Available arguments:

=over 4

=item * C<db_file>

Location to the SQLite DB file.

=item * C<dbh>

A C<DBI> filehandle to use instead of loading the file. This is useful
if you're opening an object yourself, maybe from memory, for testing maybe.

=back

=head2 word($word)

    my $word_object = $wordset->word($my_word_string);

Fetch a word from Wordset. Currently this runs an exact word match.

You receive a C<Dictionary::Wordset::Word> object. Check that class to understand
how to use it.

=head1 LIMITATIONS

=over 4

=item * You can only search for an exact word

=item * The words are available verbatim, case sensitive

=back

Patches welcome.

=head1 SEE ALSO

=over 4

=item * L<Wordset word dictionary|https://github.com/wordset/wordset-dictionary>.

=back
