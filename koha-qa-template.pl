#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

# use Smart::Comments '#####';
use List::Compare;
use List::MoreUtils qw(uniq);

use Getopt::Long;

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


my @a = get_filelist();

exit unless @a;

my $br = qx/git branch|grep '*'/;
$br =~ s/\* //g;
chomp $br;
#### $br

qx|git checkout $br  2> /dev/null  |;

# get files  from commit

qx|git checkout $br  2> /dev/null |;

qx|git branch -D qa1 2> /dev/null  |;
qx|git branch qa1 2> /dev/null  |;
qx|git checkout qa1 2> /dev/null  |;

qx|git reset --hard HEAD~$cnt 2> /dev/null  |;

# create temp git branch
my @err1 = prove_templates();

qx|git checkout $br 2> /dev/null |;

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




sub get_filelist {
    my $rc;
    my @rca = qx|git log --oneline  --numstat -$cnt|;
### @rca

    my @hs;
    my @fs;
    foreach my $z (@rca) {
        next if ( $z =~ /^\w{7} / );

        next unless $r =~ /.t$/i;

        my @a = split /\t/, $z;
        push @hs, chomp $a[2];
        push @hs, $a[2];
    }
    @hs = uniq(@hs);
    return @hs;

}








=head1 AUTHOR
Mason James <mtj at kohaaloha.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
