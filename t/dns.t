#!perl

use strict;
use warnings;

use Test::More;

use Socket;
use Mojo::IOLoop;
use Mojo::IOLoop::DNSNative;

if (not inet_aton("example.com")) {
  plan skip_all => "No DNS available";
}

my $loop = Mojo::IOLoop->new();
my $dns = Mojo::IOLoop::DNSNative->new(reactor => $loop->reactor);

$dns->lookup("example.com", sub {
  ok !$_[0], "looking up example.com didn't cause an error";
  ok @_ > 1, "looking up example.com gave us an ip";
});

$loop->start;

done_testing;
