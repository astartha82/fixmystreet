package FixMyStreet::DB::ResultSet::Comment;
use base 'DBIx::Class::ResultSet';

use strict;
use warnings;

sub timeline {
    my ( $rs, $restriction ) = @_;

    my $prefetch = 
        FixMyStreet::App->model('DB')->schema->storage->sql_maker->quote_char ?
        [ qw/user/ ] :
        [];

    return $rs->search(
        {
            state => 'confirmed',
            created => { '>=', \"ms_current_timestamp()-'7 days'::interval" },
            %{ $restriction },
        },
        {
            prefetch => $prefetch,
        }
    );
}

1;
