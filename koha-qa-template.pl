#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

#  use Smart::Comments ;
use List::Compare;
use List::MoreUtils qw(uniq);

use Getopt::Long;

use QohA::FileFind;

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


my @a = QohA::FileFind::get_test_filelist($cnt);

exit unless @a;

my $br = qx/git branch|grep '*'/;
$br =~ s/\* //g;
chomp $br;
#### $br

# get files  from commit

QohA::Git::change_branch( $br );

QohA::Git::delete_branch( 'qa1' );
QohA::Git::create_and_change_branch( 'qa1' );
QohA::Git::reset_hard( $cnt );

# create temp git branch
my @err1 = prove_templates();

QohA::Git::change_branch( $br );

# change to master branch
my @err2 = prove_templates();

##### @err1
##### @err2

my $lc = List::Compare->new( '-u', \@err2, \@err1 );

my @pass = $lc->get_intersection;
if (@pass) {

    foreach (@pass) {
        chomp;
        $_ =~ s/ \d$//;
        $_ =~ s/^\# /koha-tmpl\//;

        #        print "$_ OK\n";
    }

}

##### $lc

my @fail = $lc->get_unique;
if (@fail) {

    foreach (@fail) {
        chomp;
        $_ =~ s/ \d$//;
        $_ =~ s/^\# /koha-tmpl\//;
        print "$_ FAIL\n";
    }

}

sub prove_templates {

    my $cmd = " prove ./xt/tt_valid.t 1> /dev/null ";

##### $cmd
    my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
      run( command => $cmd, verbose => 0 );

    my @errs;
    foreach ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) {

    }

    my @f;

    my $z = $full_buf->[3];

##### $z

    my @xs = split '\n', $z if $z;

    shift @xs;

    foreach my $f (@xs) {
        my $c = $f;

        $c =~ s/^.*://g;
        $f =~ s/:.*$//g;

        my @ns = split ',', $c;
        my $n = @ns;
        #####  $n

        push @errs, "$f $n\n";

    }

    return @errs;

}

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
