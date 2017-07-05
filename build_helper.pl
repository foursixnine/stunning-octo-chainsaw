#!/usr/bin/env perl
use strict;
use warnings;

use Mojo::UserAgent;
use Getopt::Long;


my %options;

GetOptions(\%options, "h|hostname=s", "BUILD|b=s", "BUILD_SDK|s=s", "ARCH|a=s", "name|n=s", "worker|w=s",
    "EXTRAPARAMS|e=s")
  or die("options missing?");

my $ua = Mojo::UserAgent->new;
$ua->max_redirects(3);
$ua->max_response_size(0);
$ua->on(
    start => sub {
        my ($ua, $tx) = @_;
        my $progress     = 0;
        my $last_updated = time;
        $tx->res->on(
            progress => sub {
                my $msg = shift;
                $msg->finish if $msg->code == 304;
                return unless my $len = $msg->headers->content_length;
                my $size = $msg->content->progress;
                my $current = int($size / ($len / 100));
                if ($progress < $current) {
                    local $| = 1;
                    $progress = $current;
                    print "\rDownloading: - ", $size == $len ? 100 : $progress . "%";
                }
            });
    });


$options{hostname} ||= "https://openqa.suse.de";
my $base_url = new Mojo::URL->new($options{hostname});    #"${hostname}/assets/";

$options{worker}    or die("Worker class has to be set (use -w or --worker");
$options{BUILD}     or die("Build not defined (use -b or --BUILD");
$options{BUILD_SDK} or die("Build not defined (use -s or --BUILD_SDK");
my $build_name = ($options{name}) ? $options{name} . "_" . $options{BUILD} : $options{BUILD};
my $asset_name;
my $asset_url;
my $result;
$options{ARCH} or die("Build not defined (use -a or --ARCH");

my $iso_asset_name = "SLE-12-SP3-Server-DVD-" . $options{ARCH} . "-Build" . $options{BUILD} . "-Media1.iso";
$asset_url = $base_url->path("/assets/iso/")->path($iso_asset_name);

unless (-e "/var/lib/openqa/factory/iso/$iso_asset_name") {
    $result = $ua->get($asset_url)->result;
    if ($result->is_success) {
        $result->content->asset->move_to("/var/lib/openqa/factory/iso/$iso_asset_name");
    }
    elsif ($result->is_error) {
        print "Got " . $result->code . " for: " . $asset_url->to_abs();
    }
}

my $sdk_asset_name = "SLE-12-SP3-SDK-DVD-" . $options{ARCH} . "-Build" . $options{BUILD_SDK} . "-Media1.iso";
$asset_url = $base_url->path("/assets/iso/")->path($sdk_asset_name);

unless (-e "/var/lib/openqa/factory/iso/$sdk_asset_name") {
    $result = $ua->get($asset_url)->result;
    if ($result->is_success) {
        $result->content->asset->move_to("/var/lib/openqa/factory/iso/$sdk_asset_name");
    }
    elsif ($result->is_error) {
        print "Got " . $result->code . " for: " . $asset_url->to_abs();
    }
}

my $name = "build-${build_name}.json";
open(my $fd, '>', "$name");

print $fd <<END;
{
        "DISTRI": "sle",
        "BUILD_SDK": "$options{BUILD_SDK}",
        "FLAVOR": "Server-DVD",
        "ISO": "$iso_asset_name",
        "REPO_0": "$sdk_asset_name",
        "ARCH": "aarch64",
        "BUILD_SLE": "$options{BUILD}",
        "VERSION": "12-SP3",
        "BUILD": "$build_name"
}
END

my @cmd = qw(./script/client isos post _DEPRIORITIZEBUILD=1);
push @cmd, '--params', $name;
push @cmd, $options{EXTRAPARAMS} if $options{EXTRAPARAMS};
push @cmd, 'WORKER_CLASS=' . $options{worker} if $options{worker};
system(@cmd) == 0
  or die "system @cmd failed: $?";
