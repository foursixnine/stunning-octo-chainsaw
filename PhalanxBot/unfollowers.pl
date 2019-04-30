use Mojo::Base -strict;
use Mojo::JSON qw(decode_json encode_json);
use Mojo::File qw(path);
use Array::Utils qw(:all);
use Text::SimpleTable;
use Text::SimpleTable::AutoWidth;
use Getopt::Long;

my %slices;

my ( $display, $handle, $help ) = 0;

GetOptions( 'help|h|?' => \$help, 'handle|user|u:s' => \$handle, );

# they should be loaded into a database and let the database do the
# calculation for us
path("data/$handle/")->list->each( sub {
    my ($file) = @_;
    return unless m/.(\d+)\.json$/;
    s/.*\/([\d]+)\.json$/$1/;
    $slices{$_} = decode_json( $file->slurp );
} );

my @sorted = sort { $a <=> $b } keys %slices;

sub get_followers {
    my ($slice) = @_;
    my @followers = ();
    foreach my $key ( keys %{$slice} ) {
        foreach my $follower ( @{ $slice->{'followers'} } ) {
            push @followers, $follower->{screen_name};
        }
    }
    return @followers;
}

sub display_unfollows {
    my ( $epoch, @users ) = @_;
    return unless scalar @users;
    my $t2 = Text::SimpleTable::AutoWidth->new( captions => [qw(Date Handle)] );
    foreach (@users) {
        $t2->row( localtime($epoch) . " - ", $_ );
    }

    $t2->row( 'total for ' . $handle . ' as of ' . localtime($epoch), scalar @users );
    say $t2->draw;
}

my @followers;
my @unfollows;

my @yesterday_followers = ();
my $previous_slice      = undef;
my $current_slice       = undef;

foreach my $time_slice (@sorted) {
    my $current_slice = $slices{$time_slice};
    my @today_followers;
    my @today_unfollowers;
    @today_followers = get_followers $current_slice;

    # This should use user id's as keys and look for screen names somewhere else
    @today_unfollowers   = array_minus( @yesterday_followers, @today_followers );
    @yesterday_followers = @today_followers;

    display_unfollows( $time_slice, @today_unfollowers );

    $previous_slice = \$current_slice;

}

