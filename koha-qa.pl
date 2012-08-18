#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

use Getopt::Long;

use List::MoreUtils qw(uniq);

use QohA::Errors;
use QohA::Git;
use QohA::Template;
use QohA::Perl;

use Data::Dumper;

use vars qw /$v $br $num_of_commits/;

#use Smart::Comments '####';

BEGIN {

    our $v = 0;
    our $num_of_commits  = 1;

    eval "require Test::Perl::Critic::Progressive";
    die
"Test::Perl::Critic::Progressive is not installed \nrun:\ncpan install Test::Perl::Critic::Progressive\nto install it\n"
      if $@;
}

my $num_of_commits  = 1;

#print  $fux::v ;

my $r = GetOptions(

    'v:s' => \$v,
    'c:i' => \$num_of_commits,
);

our $br = QohA::Git::get_current_branch;
my ( $new_fails, $already_fails, $skip, $error_code, $full ) = 0;

eval {
    #print  "------------------------------------------";

    print "\n" . QohA::Git::log_as_string($num_of_commits);

    #warn Dumper @$new_fails;

    #    say pack("A50", "11")."22";

=c


    ( $error_code, $full ) =
      QohA::Template::init_tests( $num_of_commits, 'perlcritic_valid', 'pl' );
    print "- perlcritic-progressive tests... $error_code\n";
    print "\t$full" if $full;


=cut

    ( $error_code, $full ) =
      QohA::Template::init_tests( $num_of_commits, 'perl_valid', 'pl' );
    say pack( "A50", '- perl -c syntax tests...' ) . "$error_code";
    print "\t$full" if $full;

=c
    print "- perlcritic-progressive tests...";
    ( $new_fails, $already_fails ) = QohA::Perl::run_perl_critic($c);
    say QohA::Errors::display($new_fails);
=cut

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

    print "\t$full" if $full;

};

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
