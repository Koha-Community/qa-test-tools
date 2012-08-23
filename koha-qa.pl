#!/usr/bin/perl -w

BEGIN {
    use Getopt::Long;
    $ENV{'Smart_Comments'}  = 0;

    our ($v, $d, $c);
    our $r = GetOptions(

        'v:s' => \$v,
        'd:s' => \$d,
        'c:s' => \$c,
    );

    $v = 1 if not defined $v or $v eq '';
    $c = 1 if not defined $c or $c eq '';
    $d = 0 if not defined $d or $d eq '';

    $ENV{'Smart_Comments'}  = 1 if $d;

}


use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;
use Getopt::Long;

use QohA::Git;
use QohA::Files;

use Smart::Comments  -ENV, '####';
# define 'global' vars
use vars qw /$v $d $c $br $num_of_commits /;


BEGIN {
    eval "require Test::Perl::Critic::Progressive";
    die
"Test::Perl::Critic::Progressive is not installed \nrun:\ncpan install Test::Perl::Critic::Progressive\nto install it\n"
      if $@;
}

$c = 1 unless $c;
$num_of_commits = $c;

my $git = QohA::Git->new();
our $branch = $git->branchname;
my ( $new_fails, $already_fails, $skip, $error_code, $full ) = 0;

eval {

    print "\n" . QohA::Git::log_as_string($num_of_commits);

    my $modified_files = QohA::Files->new( { files => $git->log($num_of_commits) } );

    $git->delete_branch( 'qa-prev-commit' );
    $git->create_and_change_branch( 'qa-prev-commit' );
    $git->reset_hard_prev( $num_of_commits );

    my @perl_files = $modified_files->filter('perl');
    my @tt_files = $modified_files->filter('tt');
    my @xml_files = $modified_files->filter('xml');
    for my $f ( @perl_files, @tt_files, @xml_files ) {
        #say $f->path;
        $f->run_checks();
    }

    $git->change_branch($branch);
    $git->delete_branch( 'qa-current-commit' );
    $git->create_and_change_branch( 'qa-current-commit' );
    for my $f ( @perl_files, @tt_files, @xml_files ) {
        #say $f->path;
        $f->run_checks($num_of_commits);
    }

    for my $f ( @perl_files, @tt_files, @xml_files ) {
        say $f->report->to_string($v);
    }
};

if ($@) {
    say "\n\nAn error occured : $@";
}

$git->change_branch($branch);

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
