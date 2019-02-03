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
use Mojo::JSON qw(decode_json encode_json);
use Mojo::File qw(path);

my $client = Twitter::API->new_with_traits(
    traits => [ qw(AppAuth Enchilada) ],
    consumer_key    => $ENV{TWITTER_CONSUMER_APIKEY},
    consumer_secret => $ENV{TWITTER_CONSUMER_APISECRET},
#    -access_token        => $ENV{TWITTER_ACCESS_TOKEN},
#    -access_token_secret => $ENV{TWITTER_ACCESS_TOKENSECRET},
);

my $r = $client->oauth2_token;
my $token = $r;
my $screen_name = 'foursixnine';
$client->access_token($token);

my @followers = get_followers($client) ;

path($screen_name . '-'. time() .".json")->spurt(encode_json({followers => \@followers}));

display_followers(@followers);


sub display_followers {
    my $t2 = Text::SimpleTable::AutoWidth->new(captions => [qw(Handle Name)]);
    foreach (@_){
        $t2->row($_->{screen_name}, $_->{name});
    }

    $t2->row('total for '.$screen_name, scalar @_);
    say $t2->draw;
}

sub get_followers {
    # $client and $screen_name are globals for the time being
    my @followers;
    my $cursor = -1;
    my $token        = $ENV{TWITTER_ACCESS_TOKEN};
    my $token_secret = $ENV{TWITTER_ACCESS_TOKENSECRET};
    my $args = {screen_name => $screen_name, count => 200, cursor => $cursor, -token => $token, -token_secret => $token_secret};
    local $| = 1;
    my $counter = 0;
    # get the first page of the followers
    while (my $request = $client->followers($args)){
        my @new_followers = @{$request->{users}};
        push  @followers, @new_followers;
        $cursor = $args->{cursor} = $request->{next_cursor};
        say "Got  " . scalar @new_followers . " and next cursor is at $cursor if non 0, sleeping ($counter) ";
        last if $cursor == 0;
        # We don't sleep in the first cursor
        if ($cursor > 0 && !($counter++ % 5 == 0)){
            say 'Sleeping 300 seconds due to every 5'. $counter; 
            sleep 300;
        }
        sleep 10;
    }

    return @followers;
}
