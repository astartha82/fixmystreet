package FixMyStreet::App::Controller::Photo;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use DateTime::Format::HTTP;

=head1 NAME

FixMyStreet::App::Controller::Photo - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

Display a photo

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $id = $c->req->param('id');
    my $comment = $c->req->param('c');
    return unless ( $id || $comment );

    my $photo;

    if ( $comment ) {
        $photo = $c->model('DB::Comment')->find( {id => $comment, state => 'confirmed' } );
    } else {
        $photo = $c->model('DB::Problem')->find( {id => $id, state => 'confirmed' } );
    }

    return unless $photo;

    $photo = $photo->photo;
    if ( $c->req->param('tn' ) ) {
        $photo = _resize( $photo, 'x100' );
    } elsif ( $c->cobrand->default_photo_resize ) {
        $photo = _resize( $photo, $c->cobrand->default_photo_resize );
    }

    my $dt = DateTime->now();
    $dt->set_year( $dt->year + 1 );

    $c->res->content_type( 'image/jpeg' );
    $c->res->header( 'expires', DateTime::Format::HTTP->format_datetime( $dt ) );
    $c->res->body( $photo );
}

sub _resize {
    my ($photo, $size) = @_;
    use Image::Magick;
    my $image = Image::Magick->new;
    $image->BlobToImage($photo);
    my $err = $image->Scale(geometry => "$size>");
    throw Error::Simple("resize failed: $err") if "$err";
    my @blobs = $image->ImageToBlob();
    undef $image;
    return $blobs[0];
}

=head1 AUTHOR

Struan Donald

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;