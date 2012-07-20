#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

# use Smart::Comments ;

use Getopt::Long;
use List::MoreUtils qw(uniq);

use QohA::FileFind;
use QohA::Git;

my $v   = 0;
my $cnt = 1;

my $r = GetOptions(

    'v:s' => \$v,
    'c:i' => \$cnt,
);

use IPC::Cmd qw[can_run run];

my $run = 1;

#### $cnt

#get current branch

my $br = QohA::Git::get_current_branch;
#### $br

QohA::Git::change_branch( $br );

# get files  from commit
my @a = QohA::FileFind::get_perl_filelist( $cnt );

exit unless @a; 

#####  @a

QohA::Git::delete_branch( 'qa1' );
QohA::Git::create_and_change_branch( 'qa1' );
QohA::Git::reset_hard( $cnt );

# create temp git branch
my $f = get_history_file();

my @errs1 = run_check();

QohA::Git::change_branch( $br );

#exit;

# change to master branch
$run++;

my @errs2 = run_check();

# ## @errs1
# ## @errs2

use List::Compare;
my $lc = List::Compare->new( '-u', \@errs2, \@errs1 );

my @fail = $lc->get_unique;

### @fail
my @fail2;
my @fail3;

foreach (@fail) {
    push @fail2, $_ if $_ !~ /OK/;
}

foreach my $ss (@fail2) {

    my $full = $ss;
    $ss =~ m/compilation aborted at (.*) line/;
    $ss = $1 . " FAIL\n";

    $ss .= "\t$full\n" if $v;

    push @fail3, $ss;
}

print @fail3;

### @fail2

sub run_check {

    my @a = QohA::FileFind::get_perl_filelist($cnt);
    my @err;
    foreach my $f (@a) {
        # FIXME Why don't run with -wc ?
        my @rs = qx |perl -c $f 2>&1  |;
        my $rs = qx |perl -c $f 2>&1  |;
        #### @rs
        push @err, $rs;
    }

    # ## @err

    return @err;
}


=head1 AUTHOR
Mason James <mtj at kohaaloha.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
