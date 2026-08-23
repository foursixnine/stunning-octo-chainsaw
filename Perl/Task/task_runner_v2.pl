use Mojo::Base -strict;

package Task::Role::Task;
use Role::Tiny;

requires qw(name command);

1;

package Task::Base;
use Mojo::Base -base, -signatures;
use Role::Tiny::With;
require Carp;
with 'Task::Role::Task';

sub name {
    my $class = ref shift;
    Carp::confess("$class must have a name attribute");
}

sub command {
    my $class = ref shift;
    Carp::confess("$class must have a command attribute");
}

1;

package Task::Runner;
use Mojo::Base -base, -signatures;

has 'task';
has phases => sub { [qw(setup run teardown)] };

sub _validate_task ($self) {
    my $task = $self->task or die 'Task is required';

    for my $method (qw(name command)) {
        die "Task is missing required method '$method'" unless $task->does('Task::Role::Task');
    }

    my $name = $task->name;
    die 'Task name must be defined' unless defined $name;
    die 'Task name cannot be empty' unless length $name;

    my $command = $task->command;
    die 'Task command must be an array reference' unless ref $command eq 'ARRAY';
    die 'Task command cannot be empty' unless @$command;

    return $task;
}

sub run_phase ($self, $phase) {
    my $task = $self->_validate_task;
    my @base = $task->command->@*;
    my @argv = (@base, '--', $phase);

    say "task: " . $task->name;
    say "phase: $phase";
    say "exec: @argv";

    system @argv;

    my $exit = $? >> 8;
    die "Command failed with exit code $exit" if $exit != 0;

    return $exit;
}

sub execute ($self) {
    my @results;

    for my $phase ($self->phases->@*) {
        push @results, {
            phase => $phase,
            exit_code => $self->run_phase($phase),
        };
    }

    return \@results;
}

1;

package Task::Echo;
use Mojo::Base 'Task::Base', -signatures;

has name => 'Echo task';

sub command ($self) {
    return ['/bin/bash', '-c', 'echo "running phase: $1"'];
}

1;

package main;
use Mojo::Base -strict;

my $task   = Task::Echo->new;
my $runner = Task::Runner->new->task($task);

$runner->execute;
