package FixMyStreet::App::Controller::Location;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Encode;

=head1 NAME

FixMyStreet::App::Controller::Location - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

This is purely an internal controller for keeping all the location finding things in one place

=head1 METHODS

=head2 determine_location_from_coords

Use latitude and longitude if provided in parameters.

=cut 

sub determine_location_from_coords : Private {
    my ( $self, $c ) = @_;

    my $latitude  = $c->req->param('latitude')  || $c->req->param('lat');
    my $longitude = $c->req->param('longitude') || $c->req->param('lon');

    if ( defined $latitude && defined $longitude ) {
        $c->stash->{latitude}  = $latitude;
        $c->stash->{longitude} = $longitude;

        # Also save the pc if there is one
        if ( my $pc = $c->req->param('pc') ) {
            $c->stash->{pc} = $pc;
        }

        return 1;
    }

    return;
}

=head2 determine_location_from_pc

User has searched for a location - try to find it for them.

If one match is found returns true and lat/lng is set.

If several possible matches are found puts an array onto stash so that user can be prompted to pick one and returns false.

If no matches are found returns false.

=cut 

sub determine_location_from_pc : Private {
    my ( $self, $c ) = @_;

    # check for something to search
    my $pc = $c->req->param('pc') || return;
    $c->stash->{pc} = $pc;    # for template

    my ( $latitude, $longitude, $error ) =
      eval { FixMyStreet::Geocode::lookup( $pc, $c->fake_q ) };

    # Check that nothing blew up
    if ($@) {
        warn "Error: $@";
        return;
    }

    # If we got a lat/lng set to stash and return true
    if ( defined $latitude && defined $longitude ) {
        $c->stash->{latitude}  = $latitude;
        $c->stash->{longitude} = $longitude;
        return 1;
    }

    # $error doubles up to return multiple choices by being an array
    if ( ref($error) eq 'ARRAY' ) {
        @$error = map {
            decode_utf8($_);
            s/, United Kingdom//;
            s/, UK//;
            $_;
        } @$error;
        $c->stash->{possible_location_matches} = $error;
        return;
    }

    # pass errors back to the template
    $c->stash->{location_error} = $error;
    return;
}

=head1 AUTHOR

Struan Donald

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;