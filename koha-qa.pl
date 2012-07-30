#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

use Getopt::Long;

use List::MoreUtils qw(uniq);

use QohA::Errors;
use QohA::Git;
use QohA::Template;
use QohA::Perl;

my $c = 1;
my $v = 0;

my $r = GetOptions(

    'v:s' => \$v,
    'c:i' => \$c,
);

my $br = QohA::Git::get_current_branch;

eval {
    say QohA::Git::log_as_string($c);

    print "\n- perlcritic-progressive tests...";
    my ( $new_fails, $already_fails ) = QohA::Perl::run_perl_critic($c);
    say QohA::Errors::display($new_fails);

    print "\n- perl -c syntax tests...";
    ( $new_fails, $already_fails ) = QohA::Perl::run_check_compil($c);
    say QohA::Errors::display($new_fails);

    print "\n- xt/tt_valid.t tests...";

    # TODO with verbose mode, display $already_fails
    ( $new_fails, $already_fails ) = QohA::Template::run_tt_valid($c);
    say QohA::Errors::display_with_files($new_fails);

    print "\n- xt/author/valid-template.t tests...";
    ( $new_fails, $already_fails ) = QohA::Template::run_xt_valid_templates($c);
    say QohA::Errors::display_with_files($new_fails);

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
