use strict;
use warnings;

use Mojo::JSON qw(decode_json encode_json);
use Mojo::File qw(path);
use Mojo::Collection;
use feature 'say';

$_= path(shift);
my $file = Mojo::Collection->new(decode_json($_->slurp))->flatten;

my $filtered = $file->grep(sub{	
		$_->{MESSAGE} =~ /denied/
    });

my $regexp = qr{(.*[a-zA-Z0-9-._]+)\[(?<IP>.*)\]>?:.*};
$filtered->each(sub{
		if ($_->{'MESSAGE'} =~ /$regexp/ ){
			say "bash ./unban ".$+{'IP'};
		} else {
			warn "CANNOT GET IP: ".$_->{"MESSAGE"};
		}
    });
