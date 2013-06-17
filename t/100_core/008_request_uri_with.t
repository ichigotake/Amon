use strict;
use warnings;
use Amon2::Web::Request;
use Test::More;

my $req = Amon2::Web::Request->new(
    {
        HTTP_HOST => 'localhost',
        PATH_INFO => '/foo/',
        QUERY_STRING => 'a=b&c=d&g=%E3%81%82',
    },
);
my $uri = $req->uri_with({e => 'f'});
is_deeply +{$uri->query_form()}, {
    e => 'f',
    a => 'b',
    c => 'd',
    g => 'あ',
};

done_testing;
