package MT::Elasticsearch;
use strict;
use warnings;

use Encode;
use ElasticSearch;

our $ES;

sub _initialize {
    my $plugin = MT->component('Elasticsearch');
    my $hash   = $plugin->get_config_hash;
    my ( $server, $index ) = map { $hash->{$_} } qw( server index );
    return unless $server && $index;

    $ES = ElasticSearch->new( servers => $server, );
}

sub _get_index {
    MT->component('Elasticsearch')->get_config_value('index');
}

sub index {
    my ( $class, $entry ) = @_;
    return unless $entry;

    $ES ||= _initialize();
    return unless $ES;

    if ( $entry->status == MT::Entry::RELEASE() ) {
        $ES->index(
            index => _get_index(),
            type  => $entry->blog_id,
            id    => $entry->id,
            data  => {
                map { $_ => Encode::decode_utf8( $entry->$_ ) }
                    qw( title keywords text text_more class author_id authored_on )
            },
        );
    }
    else {
        $ES->delete(
            index => _get_index(),
            type  => $entry->class,
            id    => $entry->id,
        );
    }
}

sub delete {
    my ( $class, $entry ) = @_;
    return unless $entry;

    $ES ||= _initialize();
    return unless $ES;

    $ES->delete(
        index => _get_index(),
        type  => $entry->class,
        id    => $entry->id,
    );
}

sub search {
    my ( $class, $words ) = @_;

    $ES ||= _initialize();
    return unless $ES;

    my $res = $ES->searchqs(
        index => _get_index(),
        type  => undef,
        q     => $words,
    );

    $res;
}

1;
