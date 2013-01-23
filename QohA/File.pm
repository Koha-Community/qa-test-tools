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

has 'new_file' => (
    is => 'rw',
    default => sub {0},
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

sub check_forbidden_patterns {
    my ($self, $cnt, $patterns) = @_;

    # For the first pass, I don't want to launch any test.
    return 1 if $self->pass == 1;

    my $git = QohA::Git->new();
    my $diff_log = $git->diff_log($cnt, $self->path);
    my @forbidden_patterns = @$patterns;
    my @errors;
    my $line_number = 1;
    for my $line ( @$diff_log ) {
        if ( $line =~ m|^@@ -\d+,{0,1}\d* \+(\d+),\d+ @@| ) {
            $line_number = $1;
            next;
        }
        next if $line =~ m|^-|;
        $line_number++ and next unless $line =~ m|^\+|;
        for my $fp ( @forbidden_patterns ) {
            push @errors, "The patch introduces a forbidden pattern: " . $fp->{error} . " ($line_number)"
                if $line =~ /^\+.*$fp->{pattern}/;
        }
        $line_number++;
    }

    return @errors
        ? \@errors
        : 1;
}

sub add_to_report {
    my ($self, $name, $error) = @_;
    $self->report->add(
        {
            file => $self,
            name => $name,
            error => ( defined $error ? $error : '' ),
        }
    );
}

1;

__END__

=pod

=head1 NAME

QohA::File - common interface for a file in QohA

=head1 DESCRIPTION

This module is a wrapper that provide some common informations for a file.

=head1 AUTHORS
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha and BibLibre

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
