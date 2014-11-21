package MT::App::Search::Elasticsearch;
use strict;
use warnings;
use base qw( MT::App::Search );

use MT::Elasticsearch;

sub id {'elasticsearch'}

sub execute {
    my $app = shift;
    my ( $terms, $args ) = @_;
    my $class = $app->model( $app->{searchparam}{Type} )
        or return $app->errtrans( 'Unsupported type: [_1]',
        encode_html( $app->{searchparam}{Type} ) );

    my $search = $app->param('search');
    my $res    = MT::Elasticsearch->search($search);
    my $hits   = $res->{hits}{hits};

    my $count = @$hits;
    return $app->errtrans( "Invalid query: [_1]", $app->errstr )
        unless defined $count;

    my @ids = map { $_->{_id} } @$hits;
    my $iter = $class->load_iter( { id => \@ids } )
        or $app->error( $class->errstr );
    ( $count, $iter );
}

1;
