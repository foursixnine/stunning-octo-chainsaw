## From journal to .json

In order to convert from your journal log to json, so it is easily parseable, [jq](https://jqlang.github.io/jq/) offers an option
that allows you to run a filter, only until the end of the file:

```text
    Instead of running the filter for each JSON object in the input, read the entire input stream into a large array and
    run the filter just once.
```

This allows you to save the file directly, ready to be processed by your favorite tools, here's what I used:

`journalctl -u postfix.service --since yesterday -g "denied" --output json | jq -s "." > data/log.json`

## Enter Perl

Now, because I've been using Perl for `${deity}` knows how long (I wrote my first Perl script at the end of the 90's),
naturally, is my language of choice for quick things where my knowledge of `bash` isn't going to cut it:

First I want to load my file, I'm going to rely on [Mojo](https://docs.mojolicious.org/Mojo), specifically 
`Mojo::Collection` and `Mojo::JSON` for this as I'm familiar with both, also, if I wan't to dig a bit into what's inside
my collections, I can always do:

```perl
use Mojo::Util qw(dumper);

say dumper $collection->to_array;
```

But I digress, back to business

### The real stuff

This piece of code filters for me, what it reads from a file (I'm doing `$_= path(shift);` for convenience)

```perl
my $file = Mojo::Collection->new(decode_json($_->slurp))->flatten;

// Filter using Mojo::Collection::grep to have a new collection with the data I'm interested in
my $filtered = $file->grep(sub{ 
        $_->{MESSAGE} =~ /denied/
    });
```

Now that I have the elements on a single array (of course, if I'm looking at a file over a gigabyte, likely I'd look into
putting this inside some sort of database, PostgreSQL for instance, has excellent Json support), it's time to do something
with it:

```perl
// get anything that looks like a hostname before, and get the ip address
// example: NOQUEUE: reject: RCPT from ns2.pads.ufrj.br[146.164.48.5]: 554 5.7.1 <relaytest@antispam-ufrj.pads.ufrj.br>:
// I want to have ethe IP in a named group so I can later reference it with `$+{'IP'}`
my $regexp = qr{(.*[a-zA-Z0-9-._]+)\[(?<IP>.*)\]>?:.*};
```

Ideally (and for the future) I might want to filter in a different way, and capture different things, but you get the idea
however today, we only want to know which ip addresses were rejected while testing our changes in our postfix's configuration

```perl
$filtered->each(sub{
        if ($_->{'MESSAGE'} =~ /$regexp/ ){
            say "bash ./unban ".$+{'IP'};
        } else {
            warn "CANNOT GET IP: ".$_->{"MESSAGE"};
        }
    });
```

I have another script that does the unban, but for now I'm ok with copy&pasting :)

The full script is at: https://github.com/foursixnine/stunning-octo-chainsaw/blob/master/postfix-logparser/logparser.pl
pull requests are welcome, and maybe in the future I move this to its own thing, but for now, that's all folks.
