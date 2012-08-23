package QohA::File;

use Modern::Perl;
use Moo;
use File::Basename;
use Cwd 'abs_path';

has 'path' => (
    is => 'ro',
    required => 1,
);
has 'filename' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_filename',
);
has 'abspath' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_abspath',
);

sub _build_filename {
    my ($self) = @_;
    return basename( $self->path );
}

sub _build_abspath {
    my ($self) = @_;
    my $abs_path = abs_path( $self->path );
    return $abs_path;
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
