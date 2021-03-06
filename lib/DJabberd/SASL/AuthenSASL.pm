package DJabberd::SASL::AuthenSASL;

use strict;
use warnings;
use base qw/DJabberd::SASL/;

sub set_config_mechanisms {
    my ($self, $val) = @_;
    $self->{mechanisms} = { map { uc $_ => 1 } split /\s+/, ($val || "") };
}

sub mechanisms {
    my $plugin = shift;
    return $plugin->{mechanisms} || {};
}

sub register {
    my ($plugin, $vhost) = @_;
    $plugin->SUPER::register($vhost);

    $vhost->register_hook("SendFeatures", sub {
        my ($vh, $cb, $conn) = @_;
        if (my $sasl_conn = $conn->sasl) {
            if ($sasl_conn->is_success) {
                return;
            }
        }
        # don't offer auth without SSL
        return unless $conn->ssl;
        my @mech = $plugin->mechanisms_list;
        my $xml_mechanisms =
            "<mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>";
        $xml_mechanisms .= join "", map { "<mechanism>$_</mechanism>" } @mech;
        $xml_mechanisms .= "<optional/>" if $plugin->is_optional;
        $xml_mechanisms .= "</mechanisms>";
        $cb->stanza($xml_mechanisms);
    });
}

1;

__END__

=head1 NAME

DJabberd::SASL::AuthenSASL - SASL Negotiation using Authen::SASL

=head1 DESCRIPTION

This plugin provides straightforward support for SASL negotiations inside
DJabberd using L<Authen::SASL> (Authen::SASL::Perl, for now). It compliments
the now deprecated I<iq-auth> authentication (XEP-0078).

The recommended usage is to use STARTTLS and SASL-PLAIN.

=head1 SYNOPSIS

    <VHost yann.cyberion.net>
        <Plugin DJabberd::SASL::AuthenSASL>
            Optional   yes
            Mechanisms PLAIN LOGIN DIGEST-MD5
        </Plugin>
    </VHost>

=head1 DESCRIPTION

Only PLAIN LOGIN and DIGEST-MD5 mechanisms are supported for now (same than
in L<Authen::SASL>. DIGEST-MD5 only supports C<auth> qop (quality of
protection), so it's strongly advised to throw TLS into the mix, and not 
solely rely on DIGEST-MD5 (as opposed to C<auth-int> and C<auth-conf>).

=head1 COPYRIGHT

(c) 2009 Yann Kerherve

This module is part of the DJabberd distribution and is covered by the
distribution's overall licence.

=cut

# Local Variables:
# mode: perl
# c-basic-indent: 4
# indent-tabs-mode: nil
# End:
