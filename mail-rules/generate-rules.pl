#!/bin/perl
# TODO:: Figure out what's causing nvim to format the perl code to certain margin, it is very annoying
# Looks like it could be mason/perlnavigator package
use Mojo::Base -base, -signatures;

BEGIN {

    package MailingListRule;
    use Mojo::Base -base, -signatures;
    use Exporter qw(import);

    our @EXPORT_OK = ('inspect');

    has 'org';
    has 'repo';
    has 'host';
    has 'name';

    sub new ( $class, @args ) {
        my $self = bless {}, ref $class || $class;
        return @args ? $self->parse(@args) : $self;
    }

    sub to_string($self) {
        my $string =
          sprintf( "%s.%s.%s", $self->name, $self->org, $self->host );
        return $string;
    }

    sub parse( $self, $header ) {
        my ( $name, $org, $repo, $host );

        if (
            $header =~

            # different regexes could be a factory pattern
/(?<name>[\w\/\-_]+) <(?<repo>[\w\-_]+)\.(?<org>[\w\-_]+)\.(?<host>[\w\-_.]+)>/
          )
        {
            ( $name, $org, $repo, $host ) =
              ( $+{name}, $+{org}, $+{repo}, $+{host} );
        }

        foreach my $att (qw(name org repo host)) {
            my $code = $self->can($att) or die "No such method";
            $code->( $self, $+{$att} );
        }

        return $self;
    }

    1;
}

package main;
use Mojo::Base -strict;
use Mojo::Template;
use Mojo::Loader qw(data_section);
use Mojo::JSON   qw(decode_json encode_json);
use Mojo::File   qw(path);
use Mojo::Util   qw(trim);

sub inspect {
    use Data::Dumper;
    my $var = shift;
    say $var;
    say Dumper($var);
}

# use MailingListRule qw(inspect); # Can't do this with classes defined here :(

# an example of a list can be: <org>/<repo> <repo>.<org>.<host>>
# Correspond to Reply-To header and is the same (?) as List-Id.
#

# Say we want to make a factory to create rules, here's where to start when processing emails:
# Github: Return-Path: <notifications@github.com> and use List-Id as unique identifier
# CircleCI: Return-Path: <<bounce+random>-<user=domain>@builds.circleci.com> Maybe use Subject field

my $notification_header = shift;
my $rule_name           = shift;

my $current_rule         = MailingListRule->new($notification_header);
my $json_rules_file      = "mailrules.json";
my $processed_rules_file = "processed_mailrules.json";
my $rules                = decode_json( path($json_rules_file)->slurp );

my ( $target, $index );

for ( my $i = 0 ; $i < @{$rules} ; $i++ ) {
    if ( ${$rules}[$i]{name} eq $rule_name ) {
        $target = ${$rules}[$i];
        $index  = $i;
        say "Found " . $target->{name};
        say "With lists: " . $target->{search};
    }
}

if ($target) {
    my @lists;
    foreach my $list ( split( /OR/, $target->{search} ) ) {
        $list = trim($list);
        push @lists, $list;
    }

    push @lists, sprintf( "list:<%s>", $current_rule->to_string );

   # add new list with format sprintf("list:<string>", $current_rule->to_string)

    $target->{search} = join( ' OR ', @lists );
    inspect( $target->{'search'} );
    ${$rules}[$index] = $target;
}

path($processed_rules_file)->spew( encode_json($rules) );

say for keys %{ data_section 'main' };

__DATA__


@@ filter-list-sieve.ep
# Rule $rule_name
# Search: "filters"
if allof(
  not string :is "${stop}" "Y",
  jmapquery text:
{
   "conditions": [@conditions],
   "operator": "OR"
}
.

) {
  set "read" "Y";
  redirect :copy "$to_address";
  set "deletetotrash" "Y";
  set "stop" "Y";
}
