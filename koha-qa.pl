#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

#use Smart::Comments;

use Getopt::Long;

use List::MoreUtils qw(uniq);

my $c = 1;
my $v = 0;

my $r = GetOptions(

    'v:s' => \$v,
    'c:i' => \$c,
);

### $c

my $rc;
my @rca = qx|git log --oneline  --numstat -$c|;
### @rca

#my $h = shift @rca;
#print "- commit $h";
my @hs;
my @fs;

#    print "* changed files...\n";
foreach my $z (@rca) {
    if ( $z =~ /^\w{7} / ) {
        push @hs, $z;
        next;
    }
    else {
        push @fs, $z;
    }
}

my $h = pop @hs;
print "- $h";

foreach my $z (@fs) {
    my @a = split /\t/, $z;
    $z = $a[2];
    print "\t$z";

}
### @fs

@fs = uniq(@fs);

#    print " -\n";
### @hs

#exit;

print "- perlcritic-progressive tests...";
$rc = qx| koha-qa-critic.pl -v $v -c $c |;
print $rc ? " FAIL\n$rc" : " OK\n";

print "- perl -c syntax tests...";
$rc = qx |koha-qa-perlcheck.pl -v $v -c $c |;
print $rc ? " FAIL\n$rc" : " OK\n";

print "- xt/tt_valid.t tests...";
$rc = qx |koha-qa-template.pl -v $v -c $c |;
print $rc ? " FAIL\n$rc" : " OK\n";

print "- xt/author/vaild-template.t tests...";
$rc = qx |koha-qa-template2.pl -v $v -c $c |;
print $rc ? " FAIL\n$rc" : " OK\n";

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
