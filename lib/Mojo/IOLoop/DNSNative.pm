package Mojo::IOLoop::DNSNative;
# ABSTRACT: Async native DNS lookup
use Mojo::Base qw/ Mojo::Base /;

use List::Util qw/ uniq /;
use Mojo::IOLoop;
use Net::DNS::Native;
use Socket qw/ getnameinfo NI_NUMERICHOST NIx_NOSERV /;

has NDN => sub { state $NDN = Net::DNS::Native->new(pool => 5, extra_thread => 1) };
has reactor => sub { Mojo::IOLoop->singleton->reactor });
has timeout => 10;

sub lookup {
    my ($self, $address, $cb) = @_;

    my $reactor = $self->reactor;
    my $ndn = $self->NDN;

    my $handle = $ndn->getaddrinfo($address, undef);
    $reactor->timer($self->timeout, sub { $ndn->timedout($handle); $reactor->remove($handle); $cb->('DNS lookup timed out'); });
    $reactor->io($handle => sub {
            my $reactor = shift;
            $reactor->remove($handle);
            my ($err, @res) = $ndn->get_result($handle);

            $cb->($err, uniq map { (getnameinfo($_->{addr}, NI_NUMERICHOST, NIx_NOSERV))[1] } @res);
        }
    )->watch($handle, 1, 0);
}

1;

__END__
