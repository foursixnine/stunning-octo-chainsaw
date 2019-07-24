use Mojo::Base -base;
use Mojo::UserAgent;
use Text::Table;
use Mojo::Util 'trim';
use Mojo::File 'path';
binmode STDOUT, ':encoding(UTF-8)';
use feature 'say';

my $race_id = 324;
my @runners_list = 0; 
my $url =  "https://b2run-iframe.maxfunsports.com/result/$race_id-";
my $result_table = Text::Table->new(
    qw(Race Category Number Name Team Time Distance Status)
);

my $request = Mojo::UserAgent->new;

foreach my $runner_id (@runners_list){
    my $html = $request->get($url.$runner_id)->result;
    $result_table->load($html->dom->find('#w0 tr td')->map(sub{ return trim($_->text) })->sort->to_array);
    sleep 1;
}
say $result_table;
path('b2run2019-results.txt')->spurt($result_table);
