#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

use List::Compare;

use Getopt::Long;

use File::Find;
use File::Spec;
use Template;
use Test::More;

use List::MoreUtils qw(uniq);

use QohA::Git;
use QohA::FileFind;

#use Smart::Comments;

# use FindBin;

my $cnt = 1;
my $v   = 0;

my $r = GetOptions(

    'c:i' => \$cnt,
    'v:s' => \$v,

);

use List::Util qw(sum);

use IPC::Cmd qw[can_run run];

my $run = 1;

#### $cnt

#get current branch

my @files = QohA::FileFind::get_test_filelist( $cnt );

exit unless @files;

my $br = QohA::Git::get_current_branch();
#### $br

### @files

# get files  from commit

QohA::Git::change_branch( $br );

QohA::Git::delete_branch( 'qa1' );
QohA::Git::create_and_change_branch( 'qa1' );
QohA::Git::reset_hard( $cnt );

# create temp git branch

my $cmd = "koha-qa-template2-sub.pl  @files";
###  $cmd 

my ( $success1, $error_code1, $full_buf1, $stdout_buf1, $stderr_buf1 ) =
  run( command => $cmd, verbose => 0 );

QohA::Git::change_branch( $br );

###  $cmd 
my ( $success2, $error_code2, $full_buf2, $stdout_buf2, $stderr_buf2 ) =
  run( command => $cmd, verbose => 0 );
my $lc;



if ($v) {
    $lc = List::Compare->new( '-u', $full_buf2, $full_buf1 );
}
else {
    $lc = List::Compare->new( '-u', $stdout_buf2, $stdout_buf1 );
}



###  $full_buf1 
###  $full_buf2

###  $stdout_buf1 
###  $stdout_buf2


=c
my @pass = $lc->get_intersection;
if (@pass) {

    foreach (@pass) {
        chomp;
        $_ =~ s/ \d$//;
        $_ =~ s/^\# /koha-tmpl\//;

        #        print "$_ OK\n";
    }

}
=cut

## $lc

my @fail = $lc->get_unique;
if (@fail) {

    foreach (@fail) {
### $_

        next unless $_ =~ /not ok/;
        chomp;
        $_ =~ s|^.*koha-tmpl|koha-tmpl|;
        $_ =~ s|^|\t|;
        print "$_ FAIL\n";
    }

}

### @fail

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
