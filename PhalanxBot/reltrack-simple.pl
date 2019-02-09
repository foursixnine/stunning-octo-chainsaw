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
use Getopt::Long;
use Pod::Usage;

my $help      = 0;
my $show      = 0;
my $handle    = 0;
my $directory = 'data';
my $display   = 0;
GetOptions(
    'help|h|?'            => \$help,
    'handle|user|u:s' => \$handle,
    'directory|d'       => \$directory,
    'show|s'            => \$show
);

pod2usage( -verbose => 2 ) if $help;
pod2usage( -exitval => 126 ) unless $handle;

my $client = Twitter::API->new_with_traits(
    traits          => [qw(AppAuth Enchilada)],
    consumer_key    => $ENV{TWITTER_CONSUMER_APIKEY},
    consumer_secret => $ENV{TWITTER_CONSUMER_APISECRET},

    #    -access_token        => $ENV{TWITTER_ACCESS_TOKEN},
    #    -access_token_secret => $ENV{TWITTER_ACCESS_TOKENSECRET},
);

my $r     = $client->oauth2_token;
my $token = $r;
$client->access_token($token);

my $path = path( $directory, $handle );
mkdir $path or die( 'Cannot create directory: ' . $path ) unless -d $path;

my @followers = get_followers($client);
path( $directory, $handle, time() . ".json" )
  ->spurt( encode_json( { followers => \@followers } ) );
display_followers(@followers) if $show;

sub display_followers {
    my $t2 = Text::SimpleTable::AutoWidth->new( captions => [qw(Handle Name)] );
    foreach (@_) {
        $t2->row( $_->{handle}, $_->{name} );
    }

    $t2->row( 'total for ' . $handle, scalar @_ );
    say $t2->draw;
}

sub get_followers {
    # $client and $handle are globals for the time being
    my @followers;
    my $cursor       = -1;
    my $token        = $ENV{TWITTER_ACCESS_TOKEN};
    my $token_secret = $ENV{TWITTER_ACCESS_TOKENSECRET};
    my $args         = {
        screen_name   => $handle,
        count         => 200,
        cursor        => $cursor,
        -token        => $token,
        -token_secret => $token_secret
    };
    local $| = 1;
    my $counter = 0;
    # get the first page of the followers

    while ( my $request = $client->followers($args) ) {
        $counter++;
        my @new_followers = @{ $request->{users} };

        push @followers, @new_followers;
        $cursor = $args->{cursor} = $request->{next_cursor};

        say "Got  "
          . scalar @new_followers
          . " and next cursor is at $cursor if non 0, sleeping ($counter)";

        last if $cursor == 0;     #it's the last cursor, so let's leave
        next if $cursor == -1;    # Don't limit on the first cursor

        # We don't sleep in the first cursor
        if ( $cursor > 0 && ( ( $counter % 5 ) == 0 ) ) {
            say 'Sleeping 300 seconds due to every 5 '
              . $counter . ' - '
              . ( $counter % 5 )
              . '  -  cursor at: '
              . $cursor;
            sleep 300;
        }
        else {
            sleep 5;              # Let's not spam twitter ok?.
        }
    }

    return @followers;
}

__END__

=pod

=head1 NAME

reltrack-simple - Get list of twitter followers

=head1 SYNOPSYS

reltrack-simple.pl -u foursixnine -d path/to/directory -s

=head1 DESCRIPTION

A simple tool to get all of an arbitrary username's twitter followers, storing the raw data in .json files

=head1 OPTIONS

=over 8

=item B<--help -h>

Shows this help

=item B<--handle --user -h -u>

Specifies the username/handle to use, it is also used to create a directory where the raw json files are stored.

=item B<--directory -d>

Specifies where to store the data, the handle is used to generate a second level directory to store raw data in the
format of I<$directory/$username/$unix_time.json>

=item B<--show -s>

Whether to show a report of the followers or not (defaults to no).

=back

=head1 AUTHOR

Santiago Zarate (szarate@perl.org)

=cut
