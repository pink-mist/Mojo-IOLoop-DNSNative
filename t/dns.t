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
  ok !$_[0], "looking up 'example.com' didn't cause an error";
  ok @_ > 1, "looking up 'example.com' gave us an ip";
});

$dns->lookup("invalid.", sub {
  ok $_[0], "looking up 'invalid.' caused an error: '$_[0]'";
  ok @_ == 1, "looking up 'invalid.' didn't give us an ip";
});

$dns->lookup("localhost.", sub {
  ok !$_[0], "looking up 'localhost.' didn't cause an error";
  shift;
  ok grep($_ eq '127.0.0.1', @_),
    "looking up 'localhost.' gave us 127.0.0.1: "
    . join(', ', map "'$_'", @_) ;
});

$loop->start;

done_testing;
