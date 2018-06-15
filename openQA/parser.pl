use strict;
use warnings;
use feature 'say';
use FindBin;
use lib ("$FindBin::Bin/lib", "../lib", "lib");
use OpenQA::Parser 'parser';    # no need to 'use' every single parser implementation
use Data::Dumper;

my $parser = parser(TAP => "../t/data/tap_format_example.tap");
# $parser->write_output('.');
# equivalent to parser("JUnit")->load("my.xml");

# say "#"x10;
#$parser = parser( TAP => "../tap_format_example.tap"); # equivalent to parser("JUnit")->load("my.xml");))
#$parser = parser(LTP => "result_array.json");    # equivalent to parser("JUnit")->load("my.xml");))

$parser->tests->each(
    sub {
        map { $_->{source} = "parser" } @{$_->{details}};
    });

say Dumper($_->to_openqa) for $parser->results->each;

# map {say Dumper($_); } $parser->results();
# map {say Dumper($_); } $parser->tests()
# map {say Dumper($_); } $parser->outputs();

#print $parser->save_to_json('ltp');
#sub download_and_parse {
#    my @tests = (
#        {
#            "noteasy-file.tap" =>
#"https://gist.githubusercontent.com/foursixnine/806cd8302a4b9d6dd5d7f16fd39a489c/raw/65c40c2bdac64bf23f98f7bfed5b6a3cd401e017/test-file.tap"
#        },
#        {
#            "scheduler_dependencies.tap" =>
#"https://gist.githubusercontent.com/foursixnine/806cd8302a4b9d6dd5d7f16fd39a489c/raw/65c40c2bdac64bf23f98f7bfed5b6a3cd401e017/test-file.tap"
#        },
#        {
#            "easy-file.tap" =>
#"https://gist.githubusercontent.com/foursixnine/806cd8302a4b9d6dd5d7f16fd39a489c/raw/7428f87ecd0151b3e0a20462f760c72cc074888a/test-file.tap"
#        },
#    );

#    for my $test (@tests) {
#        say Dumper($test);
#        my ($filename) = keys %{$test};
#        say Dumper($filename);
#        my $url = $test->{$filename};
#        say("curl -k -o $filename $url");
#        say("'TAP', $filename");
#    }
#}
##download_and_parse
#
#$parser->write('./');
#say "#"x10;
#$parser = parser( XUnit => "jaxen-err.xml"); # equivalent to parser("JUnit")->load("my.xml");))
##my $parser = parser( TAP => "test.tap");
##$parsed_file->results->each(
##    sub {
##        my $result = shift; # Access to single result
##        #say Dumper($_);
##    }
##);
##

#map {say Dumper($_); } $parser->results();
#map {say Dumper($_); } $parser->tests();
#map {say Dumper($_); } $parser->outputs();
