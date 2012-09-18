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

    # Check perl critic
    $r = $self->check_critic();
    $self->report->add(
        {
            file => $self,
            name => 'critic',
            error => ( defined $r ? $r : '' ),
        }
    );

    # Check perl -cw
    $r = $self->check_valid();
    $self->report->add(
        {
            file => $self,
            name => 'valid',
            error => ( defined $r ? $r : '' ),
        }
    );

    # Check patterns
    $r = $self->check_forbidden_patterns($cnt);
    $self->report->add(
        {
            file => $self,
            name => 'forbidden patterns',
            error => ( defined $r ? $r : '' ),
        }
    );
}

sub check_critic {
    my ($self) = @_;
    my ( @ok, @ko );

    # Generate a perl critic progressive file in /tmp
    my $conf = $self->path . ".pc";
    $conf =~ s|/|-|g;
    $conf = "/tmp/$conf";

    # If it is the first pass, we have to remove the old configuration file
    if ( $self->pass == 1 ) {
        qx|rm $conf| if ( -e $conf ) ;
    }

    # If the file does not exist anymore, we return 0
    return 0 unless -e $self->path;

    # If first pass returns 0 then the file did not exist
    # And we have to pass Perl::Critic instead of Test::Perl::Critic::Progressive
    if ( $self->report->tasks->{critic}
            and $self->report->tasks->{critic}[0] == 0 ) {
        my $critic = Perl::Critic->new();
        # Serialize the violations to strings
        my @violations = map {
            my $v = $_; chomp $v; "$v";
        } $critic->critique($self->path);
        return \@violations;
    }

    # Check with Test::Perl::Critic::Progressive
    my $cmd = qq{
        perl -e "use Test::Perl::Critic::Progressive(':all');
        set_history_file('$conf');
        progressive_critic_ok('} . $self->path . qq{')"};

    my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
      run( command => $cmd, verbose => 0 );

    # If it is the first pass, we stop here
    return 1 if $self->pass == 1;

    # And if it is a success (ie. no regression)
    return 1 if $success;

    # Encapsulate the potential errors
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
    # Simple check with perl -cw
    my $path = $self->path;
    my $cmd = qq|perl -cw $path 2>&1|;
    my $rs = qx|$cmd|;
    ## File is ok if the returned string just contains "syntax OK"
    return 1 if $rs =~ /^$path syntax OK$/;
    chomp $rs;
    # Remove useless information
    $rs =~ s/\nBEGIN.*//;
    my @errors = split '\n', $rs;
    s/at .* line .*$// for @errors;
    s/.*syntax OK$// for @errors;
    @errors = grep {!/^$/} @errors;
    return \@errors;
}

sub check_forbidden_patterns {
    my ($self, $cnt) = @_;

    my @forbidden_patterns = (
        {pattern => qr{warn Data::Dumper::Dumper}, error => "Data::Dumper::Dumper"},
        {pattern => qr{<<<<<<<}, error => "merge marker (<<<<<<<)"},# git merge non terminated
        {pattern => qr{>>>>>>>}, error => "merge marker (>>>>>>>)"},
        {pattern => qr{=======}, error => "merge marker (=======)"},
        {pattern => qr{IFNULL}  , error => "IFNULL (must be replaced by COALESCE)"},  # COALESCE is preferable
        {pattern => qr{\t},     , error => "tabulation character"},  # tab caracters
        {pattern => qr{ $},    , error => "withespace character "},  # withespace caracters
    );

    return $self->SUPER::check_forbidden_patterns($cnt, \@forbidden_patterns);
}

1;

__END__

=pod

=head1 NAME

QohA::File::Perl - Representation of a Perl file in QohA

=head1 DESCRIPTION

This module allow to launch several tests on a Perl file.
Tests are: perlcritic, perl -cw and if it does not contain a line with a forbidden pattern.

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha and BibLibre

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
