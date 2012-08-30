package QohA::Files;

use Moo;
use Modern::Perl;
use List::MoreUtils qw(uniq);

use QohA::File::XML;
use QohA::File::Perl;
use QohA::File::Template;
use QohA::File::YAML;

has 'files' => (
    is => 'rw',
);

sub BUILD {
    my ( $self, $param ) = @_;
    my @files = @{$param->{files}};
    @files = uniq @files;
    $self->files([]);
    for my $file ( @files ) {
        push @{ $self->files }, QohA::File::XML->new(path => $file)
            if $file =~ qr/\.xml$|\.xsl$|\.xslt$/i;
        push @{ $self->files }, QohA::File::Perl->new(path => $file)
            if $file =~ qr/\.pl$|\.pm$/i;
        push @{ $self->files }, QohA::File::Template->new(path => $file)
            if $file =~ qr/\.tt$|\.inc$/i;
        push @{ $self->files }, QohA::File::YAML->new(path => $file)
            if $file =~ qr/\.yml$|\.yaml$/i;
    }
}

sub filter {
    my ($self, $file_type) = @_;
    my @wanted_files;
    for my $f ( @{$self->files} ) {
        given ( $file_type ) {
            when (/perl/) {
                push @wanted_files, $f
                    if ref $f eq 'QohA::File::Perl';
            }
            when (/xml/) {
                push @wanted_files, $f
                    if ref $f eq 'QohA::File::XML';
            }
            when (/tt/) {
                push @wanted_files, $f
                    if ref $f eq 'QohA::File::Template';
            }
            when (/yaml/) {
                push @wanted_files, $f
                    if ref $f eq 'QohA::File::YAML';
            }
        }
    }
    return @wanted_files;
}

1;

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
