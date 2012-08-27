package QohA::Report;

use Modern::Perl;
use Moo;
use List::Compare;

has 'type' => (
    is => 'ro',
);
has 'file' => (
    is => 'rw',
);
has 'tasks' => (
    is => 'rw',
    default => sub {return {}},
);

# Global vars
my $RED = "\e[1;31m";
my $GREEN = "\e[1;32m";
my $END = "\e[0m";
our $STATUS_KO = "${RED}FAIL${END}";
our $STATUS_OK = "${GREEN}OK${END}";

sub add {
    my ($self, $param) = @_;
    my $file = $param->{file};
    $self->file($file);
    my $name = $param->{name};
    my $error = $param->{error};

    push @{ $self->tasks->{$name} },
        defined $error ? $error : 1;
}

sub to_string {
    my ($self, $verbosity) = @_;
    my $tasks = $self->tasks;
    my ( $v1, $v2 );
    my $errors_cpt = 0;
    my ($status, $v1_status);
    while ( my ($name, $results) = each %$tasks ) {
        my @diff = $self->diff($results);
        $v1 .= pack( "A30", "\n\t$name");
        if ( @diff ) {
            $errors_cpt++;
            $v1 .= $STATUS_KO;
            if ( $verbosity >= 2 ) {
                for my $d ( @diff ) {
                    $v1 .= "\n\t\t$d";
                }
            }
            next;
        }
        $v1 .= $STATUS_OK;
    }
    $status = $errors_cpt
        ? $STATUS_KO
        : $STATUS_OK;
    my $s = pack( "A75", "* " . $self->file->path ) . $status;
    $s .= $v1 if $verbosity >= 1;

    return $s;
}

sub diff {
    my ($self, $errors) = @_;
    my ($before, $current) = @$errors;

    unless ( ref $current or ref $before ) {
        if ( "$current" ~~ "$before" ) {
            return;
        }
        return ($current);
    }
    if ( ref $current ne ref $before ) {
        $before = [$before];
    }

    my $lc = List::Compare->new( '-u', $current, $before );

    return $lc->get_unique;
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
