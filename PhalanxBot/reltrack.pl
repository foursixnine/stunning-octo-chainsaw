#!/usr/bin/env perl
# https://developer.twitter.com/en/apps/776620
use warnings;
use strict;
use utf8;
use feature 'say';
use open qw/:std :utf8/;
use Net::Twitter:Tracker;

my @followers = get_followers($self->client) ;


sub display_followers {
    my $t2 = Text::SimpleTable::AutoWidth->new(captions => [qw(Handle Name)]);
    foreach (@_){
        $t2->row($_->{screen_name}, $_->{name});
    }

    $t2->row('total for '.$screen_name, scalar @_);
    say $t2->draw;
}

display_followers(@followers);
