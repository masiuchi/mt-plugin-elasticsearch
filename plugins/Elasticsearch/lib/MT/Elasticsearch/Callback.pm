package MT::Elasticsearch::Callback;
use strict;
use warnings;

use MT::App::Search;
use MT::App::Search::Elasticsearch;
use MT::Elasticsearch;

sub init_app {
    no warnings 'redefine';
    *MT::App::Search::execute = \&MT::App::Search::Elasticsearch::execute;
}

sub post_save {
    my ( $cb, $obj, $orig_obj ) = @_;
    MT::Elasticsearch->index($obj);
}

sub post_remove {
    my ( $cb, $obj ) = @_;
    MT::Elasticsearch->delete($obj);
}

1;
