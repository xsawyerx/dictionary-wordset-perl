requires 'Moose'           => '0';
requires 'Path::Tiny'      => '0';
requires 'Sereal::Decoder' => '0.88';

on 'test' => sub {
    requires 'Test::More' => '0.96';
};
