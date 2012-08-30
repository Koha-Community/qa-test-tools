package QohA::File::YAML;

use Modern::Perl;
use Moo;
use YAML;

use QohA::Report;
extends 'QohA::File';

has 'report' => (
    is => 'rw',
    default => sub {
        QohA::Report->new( {type => 'yaml'} );
    },
);

sub run_checks {
    my ($self) = @_;
    my @r = $self->check_parse_yaml();
    $self->report->add(
        {
            file => $self,
            name => 'yaml_valid',
            error => ( @r ? \@r : '' ),
        }
    );
}

sub check_parse_yaml {
    my ($self) = @_;
    return 1 unless -e $self->path;
    eval { YAML::LoadFile($self->abspath); };
    return 1 unless $@;

    my @r;
    for my $line ( split '\n', $@ ) {
        next unless $line;
        next unless $line =~ /YAML Error/;
        push @r, $line;
    }
    return @r;
}


1;

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha and BibLibre

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
