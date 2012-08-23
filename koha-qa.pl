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
use List::MoreUtils qw(uniq);

use QohA::Errors;
use QohA::Git;
use QohA::Template;
use QohA::Perl;

use Smart::Comments  -ENV, '####';
# define 'global' vars
use vars qw /$v $d $c $br $num_of_commits /;



BEGIN {

    eval "require Test::Perl::Critic::Progressive";
    die
"Test::Perl::Critic::Progressive is not installed \nrun:\ncpan install Test::Perl::Critic::Progressive\nto install it\n"
      if $@;

}

#warn $v;

    $c = 1 unless $c;
    #$v = 1 unless $v;

    $num_of_commits = $c;

    our $br = QohA::Git::get_current_branch;
    my ( $new_fails, $already_fails, $skip, $error_code, $full ) = 0;

my $buf;
my $err;

eval {

local *STDOUT;
open(STDOUT, '>', \$buf);

# local *STDERR;
# open(STDERR, '>', \$err);



    print "\n" . QohA::Git::log_as_string($num_of_commits);


    ( $new_fails, $already_fails ) = QohA::Perl::run_perl_critic($num_of_commits);
    ( $error_code, $full ) = QohA::Errors::display($new_fails);
    say pack( "A50", '- perlcritic-progressive tests...' ) . "$error_code";
    print "\t$full" if $full;


    ( $error_code, $full ) =
      QohA::Template::init_tests( $num_of_commits, 'perl_valid', 'perl' );
    say pack( "A50", '- perl -c syntax tests...' ) . "$error_code";
    print "\t$full" if $full;


    ( $error_code, $full ) =
      QohA::Template::init_tests( $num_of_commits, 'tt_valid', 'tt' );
    say pack( "A50", "- xt/tt_valid.t tests..." ) . "$error_code";
    print "\t$full" if $full;

    ( $error_code, $full ) =
      QohA::Template::init_tests( $num_of_commits, 'valid_templates', 'tt' );
    say pack( "A50", "- xt/author/valid-template.t tests..." ) . "$error_code";
    print "\t$full" if $full;

    ( $error_code, $full ) =
      QohA::Template::init_tests( $num_of_commits, 'xml_valid', 'xml' );
    say pack( "A50", "- t/00-valid-xml.t tests..." ) . "$error_code";
    print "\t$full" if $full;

    print "\n";

};

print $buf if $buf and $v;

if ($@) {
    say "\n\nAn error occured : $@";
}

QohA::Git::change_branch($br);

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
