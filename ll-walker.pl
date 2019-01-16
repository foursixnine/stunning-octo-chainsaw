#!/usr/bin/perl -w
# Given that old local::lib directory still exists
# figure out what modules were installed there
# specially useful if using local::lib on a rolling release distribution
# Which hhelps solving: loadable library and perl binaries are mismatched
# https://rt.perl.org/Public/Bug/Display.html?id=133440#txn-1582249


use strict;
use IO::Dir;
use ExtUtils::Packlist;
use ExtUtils::Installed;
use Mojo::UserAgent;
use feature 'say';

my $ua = Mojo::UserAgent->new;

sub query {
    my ($package) = @_;
    my $res = $ua->get("https://fastapi.metacpan.org/v1/module/$package")->result;
    if ($res->is_success && $res->code eq 200){
        return $package;
    } elsif ($res->is_error) {
        say "Package $package: ". $res->message;
        return 'not a package';
    }

    die "$package caused death!";
}

# Find all the installed packages
print("Finding all installed modules...\n");
my @inc = qw(/home/foursixnine/old_perl5);
my $installed = ExtUtils::Installed->new( inc_override => \@inc );

foreach my $module (grep(!/^Perl$/, $installed->modules())) {
   my $version = $installed->version($module) || "???";
   if (query($module) eq $module){
       say "Found module $module";
   } else {
       say "Found module $module is not a package";
   }
}
