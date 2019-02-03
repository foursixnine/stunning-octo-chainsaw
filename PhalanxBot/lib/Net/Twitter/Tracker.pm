package Net::Twitter:Tracker;

use Mojo::Base -base;
use Mojo::Log;

use Twitter::API;
use Data::Dump qw(pp);
use Text::SimpleTable::AutoWidth;
use Mojo::JSON qw(decode_json encode_json);
use Mojo::File qw(path);

has logger => sub {
    return Mojo::Log->new( level => 'info' );
};

has log => sub {
    logger->info(@_);
};

sub new { bless {}, shift };

has 'screen_name';
has client => sub {
    return Twitter::API->new_with_traits(
        traits => [ qw(AppAuth Enchilada) ],
        consumer_key    => $ENV{TWITTER_CONSUMER_APIKEY},
        consumer_secret => $ENV{TWITTER_CONSUMER_APISECRET},
    #    -access_token        => $ENV{TWITTER_ACCESS_TOKEN},
    #    -access_token_secret => $ENV{TWITTER_ACCESS_TOKENSECRET},
    );
};

sub store {
    path($screen_name . '-'. time() .".json")->spurt(encode_json({followers => \@followers}));
};

my $r = $self->client->oauth2_token;
my $token = $r;
$self->client->access_token($token);

sub get_followers {
    my $self = @_;
    # $self->client and $screen_name are globals for the time being
    my @followers;
    my $cursor = -1;
    my $token        = $ENV{TWITTER_ACCESS_TOKEN};
    my $token_secret = $ENV{TWITTER_ACCESS_TOKENSECRET};
    my $args = {screen_name => $screen_name, count => 200, cursor => $cursor, -token => $token, -token_secret => $token_secret};
    local $| = 1;
    my $counter = 0;
    # get the first page of the followers
    # this part here needs to be an iterator
    while (my $request = $self->client->followers($args)){
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
