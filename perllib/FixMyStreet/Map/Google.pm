#!/usr/bin/perl
#
# FixMyStreet:Map::Google
# Google maps on FixMyStreet.
#
# Copyright (c) 2010 UK Citizens Online Democracy. All rights reserved.
# Email: matthew@mysociety.org; WWW: http://www.mysociety.org/

package FixMyStreet::Map::Google;

use strict;
use mySociety::Web qw(ent);

# display_map C PARAMS
# PARAMS include:
# latitude, longitude for the centre point of the map
# CLICKABLE is set if the map is clickable
# PINS is array of pins to show, location and colour
sub display_map {
    my ($self, $c, %params) = @_;
    $c->stash->{map} = {
        %params,
        type => 'google',
    };
}

1;
