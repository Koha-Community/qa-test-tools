package QohA::File::Perl;

use Modern::Perl;
use Moo;
extends 'QohA::File';

use Test::Perl::Critic::Progressive(':all');
use Perl::Critic qw[critique];
use IPC::Cmd qw[can_run run];

use QohA::Git;
use QohA::Report;

has 'pass' => (
    is => 'rw',
    default => sub{0},
);

has 'report' => (
    is => 'rw',
    default => sub {
        QohA::Report->new( {type => 'perl'} );
    },
);

sub run_checks {
    my ($self, $cnt) = @_;

    my $r;
    $self->pass($self->pass + 1);

    if ( $self->pass == 1 ) {
        $r = $self->check_critic( 'tmp' );
    } else {
        $r = $self->check_critic( 'master' );
    }
    $self->report->add(
        {
            file => $self,
            name => 'critic',
            error => ( defined $r ? $r : '' ),
        }
    );

    $r = $self->check_valid();
    $self->report->add(
        {
            file => $self,
            name => 'valid',
            error => ( defined $r ? $r : '' ),
        }
    );

    if ( $self->pass == 1 ) {
        $self->report->add(
            {
                file => $self,
                name => 'forbidden patterns',
                error => ''
            }
        );
    } else {
        $r = $self->check_forbidden_patterns($cnt);
        $self->report->add(
            {
                file => $self,
                name => 'forbidden patterns',
                error => ( defined $r ? $r : '' ),
            }
        );
    }

}

sub check_critic {
    my ($self, $branch) = @_;
    my ( @ok, @ko );

    return 0 unless -e $self->path;

    # If first pass returns 0 then the file did not exist
    # And we have to pass Perl::Critic instead of Test::Perl::Critic::Progressive
    if ( $self->report->tasks->{critic}
            and $self->report->tasks->{critic}[0] == 0 ) {
        my $critic = Perl::Critic->new();
        my @violations = map {
            my $v = $_; chomp $v; "$v";
        } $critic->critique($self->path);
        return \@violations;
    }

    my $conf = $self->path . ".pc";
    $conf =~ s|/|-|g;
    $conf = "/tmp/$conf";

    if ( $branch eq 'tmp' ) {
        qx|rm $conf | if ( -e $conf ) ;
        qx|cp $conf $conf.1 | if ( -e $conf ) ;
    } else {
        qx|cp $conf $conf.2 | if ( -e $conf ) ;
    }


    my $cmd = qq{
        perl -e "use Test::Perl::Critic::Progressive(':all');
        set_history_file('$conf');
        progressive_critic_ok('} . $self->path . qq{')"};

    my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
      run( command => $cmd, verbose => 0 );

    return 1 if $branch eq 'tmp';
    return 1 if $success;

    my @errors;
    for my $line (@$full_buf) {
        chomp $line;

        $line =~ s/Expected no more than.*$//g;

        next if $line =~ qr/Too many Perl::Critic violations/;

        push @errors, $line if $line =~ qr/violation/;
    }

    return @errors
        ? \@errors
        : 1;
}

sub check_valid {
    my ($self) = @_;
    return 1 unless -e $self->path;
    my $cmd = qq|perl -cw | . $self->path . qq| 2>&1|;
    my $rs = qx|$cmd|;
    return 1 if $rs =~ /syntax OK/;
    chomp $rs;
    $rs =~ s/\nBEGIN.*//;
    my @errors = split '\n', $rs;
    return \@errors;
}

sub check_forbidden_patterns {
    my ($self, $cnt) = @_;
    my $git = QohA::Git->new();
    my $diff_log = $git->diff_log($cnt, $self->path);
    my @forbidden_patterns = (
        qq{warn Data::Dumper::Dumper},
        qq{^<<<<<<<},
        qq{^>>>>>>>},
        qq{^=======},
        qq{IFNULL},
    );
    my @errors;
    for my $line ( @$diff_log ) {
        next unless $line =~ m|^\+|;
        for my $fp ( @forbidden_patterns ) {
            push @errors, "The patch introduces a forbidden pattern: $fp"
                if $line =~ m/$fp/;
        }
    }
    return \@errors;
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
