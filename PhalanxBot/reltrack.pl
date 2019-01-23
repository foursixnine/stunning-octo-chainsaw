#!/usr/bin/env perl
# https://developer.twitter.com/en/apps/776620
use warnings;
use strict;
use utf8;
use feature 'say';
use open qw/:std :utf8/;

use Twitter::API;
use Data::Dump qw(pp);
use Text::SimpleTable::AutoWidth;

my $client = Twitter::API->new_with_traits(
    traits => [ qw(AppAuth Enchilada) ],
    consumer_key    => $ENV{TWITTER_CONSUMER_APIKEY},
    consumer_secret => $ENV{TWITTER_CONSUMER_APISECRET},
#    -access_token        => $ENV{TWITTER_ACCESS_TOKEN},
#    -access_token_secret => $ENV{TWITTER_ACCESS_TOKENSECRET},
);

sub display_followers {
    my $t2 = Text::SimpleTable::AutoWidth->new(captions => [qw(Handle Name)]);
    foreach (@_){
        $t2->row($_->{screen_name}, $_->{name});
    }

    $t2->row('total', scalar @_);
    say $t2->draw;
}

sub get_followers {
    my @followers;
    my $cursor = -1;
    my $token        = $ENV{TWITTER_ACCESS_TOKEN};
    my $token_secret = $ENV{TWITTER_ACCESS_TOKENSECRET};
    my $args = {screen_name => 'foursixnine', count => 200, cursor => $cursor, -token => $token, -token_secret => $token_secret};
    local $| = 1;
    # get the first page of the followers
    while (my $request = $client->followers($args)){
        my @new_followers = @{$request->{users}};
        push  @followers, @new_followers;
        $cursor = $args->{cursor} = $request->{next_cursor};
        last if $cursor == 0;
        say "Got  " . scalar @new_followers . " and next cursor is at $cursor, sleeping ";
        sleep 10;
    }

    return @followers;
}


my $r = $client->oauth2_token;
my $token = $r;
$client->access_token($token);

my @followers = get_followers($client) ;

display_followers(@followers);


