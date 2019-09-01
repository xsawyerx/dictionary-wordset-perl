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
