#!/usr/bin/perl
use strict;
use warnings;
use Sereal::Encoder;
use JSON::MaybeXS qw< decode_json >;
use Path::Tiny qw< path >;

my $encoder = Sereal::Encoder->new({
    'compress'       => 1,
    'compress_level' => 9,
    'dedupe_strings' => 1,
});

my $orig_dict = 'wordset-dictionary/data';
my $srl_dict  = 'data';
path($orig_dict)->visit(sub {
    my $file = shift;

    $file->is_file && $file =~ /\.json$/xms
        or return;

    my $content  = decode_json( $file->slurp );
    my $bin_file = $file =~ s{^\Q$orig_dict\E/(.+)\.json$}{$srl_dict/$1.srl}xmsr;

    path($bin_file)->spew_raw( $encoder->encode($content) );
}, { 'recurse' => 1 });
