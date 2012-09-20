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
    my ($self, $params) = @_;
    my $verbosity = $params->{verbosity} // 0;
    my $color     = $params->{color} // 1;
    my $task_name = $params->{name};

    my $STATUS_KO = $color
        ? "${RED}FAIL${END}"
        : "FAIL";
    my $STATUS_OK = $color
        ? "${GREEN}OK${END}"
        : "OK";

    my $tasks = $self->tasks;
    if ( defined $task_name ) {
        $tasks = { $task_name => $tasks->{$task_name} }
    }

    my ( $v1, $v2 );
    my $errors_cpt = 0;
    my ($status, $v1_status);
    while ( my ($name, $results) = each %$tasks ) {
        my @diff = $self->diff($results);
        $v1 .= pack( "A30", "\n\t$name");
        if ( @diff ) {
            my @diff_ko;
            for my $d ( @diff ) {
                next unless $d;  # if $d eq "" FIXME
                next if $d =~ /^\d$/ and $d ~~ 1; # if $d == 1  We have to bring consistency for the returns of the check* routine
                push @diff_ko, $d;
            }
            if ( @diff_ko ) {
                $errors_cpt++;
                $v1 .= $STATUS_KO;
                if ( $verbosity >= 2 ) {
                    $v1 .= "\n\t\t$_" for @diff
                }
                next;
            }
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

    $current = [$current] unless ref $current;
    $before  = [$before]  unless ref $before;

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
