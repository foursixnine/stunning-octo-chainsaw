BEGIN {
   *CORE::GLOBAL::die = sub {
        use feature qw(say);
        say "My die";
        CORE::die( @_ ) if $^S;
        use Devel::StackTrace;
        print 'Error: ' . @_ . "\n"
        . "Stack trace:\n"
        . Devel::StackTrace->new(no_refs => 1)->as_string, "\n";
        exit 1;
    };
}

package Utils;
use Mojo::Base -strict;

sub inspect {
    use Data::Dumper;
    my $var = shift;
    say Dumper($var);
}

package Task::Runner;
use Mojo::Base -signatures, -base;

has 'task';

sub new {
    my @args = @_;
    my $self = shift->SUPER::new;
    my $task = shift;

    unless ($task->isa('Task::AbstractTask')){
        die "A new Task must be subclass of Task::AbstractTask";
    }

    $self->task($task);
    return $self;

}

sub setup {
    my ($self) = @_;
    my @args = $self->task->command->@*;
    _run('setup', @args);
}

sub teardown {
    my ($self) = @_;
    my @args = $self->task->command->@*;
    _run('teardown', @args);
}

sub run {
    my ($self) = @_;
    my @args = $self->task->command->@*;
    my $exit_code = _run('run', @args);
    $self->task->state('ran', $exit_code);
}

sub _run($phase, @args){
    push @args, '--';
    push @args, $phase;

    system @args;
    my $exit_code = $? >> 8;
    if ($exit_code != 0) {
        die "Command failed: $exit_code";
    }
    return $exit_code
}

package Task::Runner::AbstractExecutor;
use Mojo::Base -signatures, -base, -role;

has 'task';

requires qw(execute);

package Task::Runner::Role::CanExecute;
use Mojo::Base 'Task::Runner::AbstractExecutor', -signatures, -base, -role;

has name => __PACKAGE__;

requires qw(run setup teardown);

sub execute($self){
    $self->setup;
    $self->run;
    $self->teardown;
}

package Task::AbstractTask;
use Mojo::Base -signatures, -base;

has state => sub($self) {
    return $self->task->state;
};

package Task::BashTask;
use Mojo::Base 'Task::AbstractTask', -signatures, -base;

has name => "My bash task";
has command => sub {
    ['/bin/bash', '-c', 'echo "running phase: $1"']
};

1;

package main;

sub run {
    my %args = ();
    my $task = Task::BashTask->new;

    my $runner = Task::Runner->with_roles('+CanExecute')->new($task);
    $runner->execute();
}

run;
