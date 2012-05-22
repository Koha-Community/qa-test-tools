#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

# use Smart::Comments '###';

use Getopt::Long;
use List::MoreUtils qw(uniq);

my $v   = 0;
my $cnt = 1;

my $r = GetOptions(

    'v:s' => \$v,
    'c:i' => \$cnt,
);

use IPC::Cmd qw[can_run run];

my $run = 1;

#### $cnt

#qx|git checkout master  2> /dev/null |;

#get current branch

my $br = qx/git branch|grep '*'/;
$br =~ s/\* //g;
chomp $br;
#### $br

qx|git checkout $br  2> /dev/null  |;

# get files  from commit
my @a = get_filelist();

exit unless @a; 

#####  @a

qx|git checkout $br  2> /dev/null |;

qx|git branch -D qa1 2> /dev/null  |;
qx|git branch qa1 2> /dev/null  |;
qx|git checkout qa1 2> /dev/null  |;

qx|git reset --hard HEAD~$cnt 2> /dev/null  |;

# create temp git branch
my $f = get_history_file();

my @errs1 = run_check();

qx|git checkout $br 2> /dev/null |;

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

    my @a = get_filelist();
    my @err;
    foreach my $f (@a) {
        my @rs = qx |perl -c $f 2>&1  |;
        my $rs = qx |perl -c $f 2>&1  |;
        #### @rs
        push @err, $rs;
    }

    # ## @err

    return @err;
}

sub get_filelist {
    my $rc;
    my @rca = qx|git log --oneline  --numstat -$cnt|;
### @rca

    my @hs;
    my @fs;
    foreach my $z (@rca) {
        next if ( $z =~ /^\w{7} / );

        next if $z =~ /.tt$/;
        next unless $r =~ /\.pm$|\.pl$|\.t$/i;

        chomp $a[2];
        push @hs, $a[2];
    }
    @hs = uniq(@hs);
    return @hs;
### @hs

}

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
