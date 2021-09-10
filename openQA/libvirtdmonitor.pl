use strict;
use warnings;
use utf8;
use feature ':5.16';
use Data::Dumper;

use constant DEBUG => 0;

sub get_domain_description {
	say (( caller(0) )[3]) if DEBUG;
	my ($domain) = @_;
	`virsh desc $domain`;
	`virsh domiflist $domain`;
}

sub get_running_machines {
	say (( caller(0) )[3]) if DEBUG;
	my (undef,undef,@all_domains) = split/\n/, `virsh list --all`;
	my @machines;
	if (@all_domains > 0){
		foreach my $this_domain (@all_domains){
			chomp $this_domain;
			my $record = {};
			$this_domain =~ s/ +/ /g;
			my (undef,undef,@domain_data) = split /\s/, $this_domain;
			$record->{domain} = $domain_data[0] // 'no domain available';
			$record->{status} = $domain_data[1] // 'no domain available';
			push @machines, $record;
		}
	}
	return @machines;
}

sub get_ip_data {
	say (( caller(0) )[3]) if DEBUG;
	`ip -a a`
}

sub get_qemu_processes {
	say (( caller(0) )[3]) if DEBUG;
	split/\n/, `ps -C qemu-system-\$(uname -m) -o args --no-headers`;
}

sub process_line {
	say (( caller(0) )[3]) if DEBUG;
	my ($line) = @_;
	say "BEGIN PROCESSING:\t$line";
	say get_ip_data;
	my @virsh_machines = get_running_machines;
	for my $this_machine (@virsh_machines){
		say Dumper(\$this_machine) if DEBUG;
		say $this_machine->{domain} if DEBUG;
		say get_domain_description($this_machine->{domain});
	}
	my @qemu_processes = get_qemu_processes;
	if (@virsh_machines lt @qemu_processes){
		warn "There are less virsh domains than machines running, might be a problem";
	}
	say "FINISH PROCESSING:\t$line";
}

while(<>){
	# screen -S bobby -L
	# journalctl -fu libvirtd | perl libvirtdmonitor.pl
	process_line $_ if $_ =~ /Address already in use/
}