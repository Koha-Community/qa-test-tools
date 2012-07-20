#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive qw / get_history_file/;

#use Smart::Comments;

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

#FIXME There is not a simple way to get the current branch ?
my $br = QohA::Git::get_current_branch;
#### $br

QohA::Git::change_branch( $br );

# get files  from commit
my @a = QohA::FileFind::get_perl_filelist($cnt);

exit unless @a;


QohA::Git::delete_branch( 'qa1' );
QohA::Git::create_and_change_branch( 'qa1' );
QohA::Git::reset_hard( $cnt );

# create temp git branch
my $f = get_history_file();

run_critic(@a);

QohA::Git::change_branch( $br );

#exit;

# change to master branch
$run++;
run_critic(@a);

sub run_critic {
    my @files = @_;

    foreach my $f (@files) {

        #        my $cmd = " perl ~/bin/koha-qa-critic-sub.pl $f 2> /dev/null";

        # test a file
        next unless ( -e $f );

        my $conf = "$f.pc";
        $conf =~ s/\//\-/g;
        $conf = "/tmp/$conf";

        if ( $run == 1 ) {
            qx|rm $conf | if ( -e $conf );

        }

        my $cmd = "koha-qa-critic-sub.pl $f $conf";

        my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
          run( command => $cmd, verbose => 0 );

        #        my @r = qx/$cmd/;
        #        my $w;
        #        $w = $r[1];

        #        if ( $run == 2 and $w =~ /not ok/ ) {
        if ( $run == 2 ) {

            #            warn "----------------------------------\n";

            my @err;

            my $w = $stdout_buf;

            foreach (@$full_buf) {

                $_ =~ s/Expected no more than.*$//g;
                $_ =~ s/^/\t/;
                push @err, $_ if $_ =~ qr/violation/;

            }

            pop @err;

            #       $w =~ s/1 - Test::Perl::Critic::Progressive$//g;
            #       $w =~ s/^[ \t]+|[ \t]+$//g;

            #            $w =~ s/ok$/OK/;
            #       $w =~ s/not ok$/FAIL/;
            #       $w =~ s/ok$/OK/;

            if ($error_code) {
                print "$f: FAIL\n";
                print @err       if @err;
                print @$full_buf if $v;

            }
            elsif ($v) {

                print "$f: OK\n";
            }

        }
    }

}

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
