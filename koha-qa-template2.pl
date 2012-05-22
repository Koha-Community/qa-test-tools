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

#qx|git checkout master  2> /dev/null |;

#get current branch

my @files = get_filelist();

exit unless @files;


my $br = qx/git branch|grep '*'/;
$br =~ s/\* //g;
chomp $br;
#### $br

qx|git checkout $br  2> /dev/null  |;

### @files

# get files  from commit

qx|git checkout $br  2> /dev/null |;

qx|git branch -D qa1 2> /dev/null  |;
qx|git branch qa1 2> /dev/null  |;
qx|git checkout qa1 2> /dev/null  |;

qx|git reset --hard HEAD~$cnt 2> /dev/null  |;

# create temp git branch

my $cmd = "koha-qa-template2-sub.pl  @files";
###  $cmd 

my ( $success1, $error_code1, $full_buf1, $stdout_buf1, $stderr_buf1 ) =
  run( command => $cmd, verbose => 0 );

qx|git checkout $br 2> /dev/null |;

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

sub get_filelist {
    my $rc;
    my @rca = qx|git log --oneline  --numstat -$cnt|;
### @rca

    my @hs;
    my @fs;
    foreach my $z (@rca) {
        next if ( $z =~ /^\w{7} / );

        next unless $z =~ /.tt$/;
        my @a = split /\t/, $z;

        chomp $a[2];
        push @hs,  $a[2];
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
