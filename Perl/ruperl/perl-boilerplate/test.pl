use feature 'say';
my $string = "hello";
foo($string);

sub foo {
    say "foo says: @_\n";
}
