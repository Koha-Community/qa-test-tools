package QohA::Perl;

use Modern::Perl;

use List::MoreUtils qw/uniq/;
use Test::Perl::Critic::Progressive(':all');
use IPC::Cmd qw[can_run run];

use QohA::Git;
use QohA::Errors;

use Smart::Comments  -ENV, '####';
use Data::Dumper;


sub run_perl_critic {



    my ($num_of_commits) = @_;

    my @files = QohA::FileFind::get_files($num_of_commits, 'perl');
    return unless @files;

    QohA::Git::delete_branch('qa-prev-commit');
    QohA::Git::create_and_change_branch('qa-prev-commit');
    QohA::Git::reset_hard_prev($num_of_commits);
    #my $f = get_history_file();

    my ( $ko1, $ok1 ) = run_critic( 'tmp', @files );

    QohA::Git::change_branch($main::br);
    QohA::Git::delete_branch('qa-head-commit');
    QohA::Git::create_and_change_branch('qa-head-commit');

    my ( $ko2, $ok2 ) = run_critic( 'master', @files );


    QohA::Git::change_branch($main::br);
    return QohA::Errors::compare_errors( $ko1, $ko2 );



}


sub run_critic {


    my $branch = shift;
    my @files  = @_;
    my ( @ok, @ko );

    foreach my $f (@files) {
        next unless ( -e $f );

        my $conf = "$f.pc";
        $conf =~ s/\//\-/g;
        $conf = "/tmp/$conf";

        if ( $branch eq 'tmp' ) {
            qx|rm $conf | if ( -e $conf ) ;
            qx|cp $conf $conf.1 |if ( -e $conf ) ;
        } else {
            qx|cp $conf $conf.2 |if ( -e $conf ) ;
        }

#warn 'aaaaaa';
        my $cmd = qq{
            perl -e "
            local *STDOUT;
            open(STDOUT, '>', \$buf);
            use Test::Perl::Critic::Progressive(':all');
            set_history_file('$conf');
            progressive_critic_ok('$f')
            " > /dev/null

        };

#warn $cmd;

        my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
          run( command => $cmd, verbose => 0 );


    #my $foo = qx|cat /tmp/aaa|;
#warn $foo;
    #warn Dumper ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf );


        next if $branch eq 'tmp';

        if ($success) {
            push @ok, $f;
            next;
        }

        my @errors;
        for my $line (@$full_buf) {
            chomp $line;

            die
"The module Test::Perl::Critic::Progressive is not installed. Please install it !"
              if $line =~ m{Can't locate Test/Perl/Critic/Progressive};

            $line =~ s/Expected no more than.*$//g;

            next if $line =~ qr/Too many Perl::Critic violations/;

            push @errors, $line if $line =~ qr/violation/;
        }

        # TODO Here we want a more complex structure, like:
        # {
        #    $file => {
        #       errors => [
        #           err1, err2
        #       ],
        #       verbose => $full_buf
        #   }
        #}
        # But it is more difficult to compare 2 structures
        if (@errors) {
            push @ko, "$f\n\t" . join "\n\t", @errors;
        }
    }
    return ( \@ko, \@ok );
}

=c
sub run_perl_critic2 {
    my ($cnt) = @_;

    my @files = QohA::FileFind::get_perl_files($cnt);
    return unless @files;

    my $br = QohA::Git::get_current_branch;

    QohA::Git::delete_branch('qa1');
    QohA::Git::create_and_change_branch('qa1');
    QohA::Git::reset_hard($cnt);

    my $f = get_history_file();
    my ( $ko1, $ok1 ) = run_critic( 'tmp', @files );

    QohA::Git::change_branch($br);
    my ( $ko2, $ok2 ) = run_critic( 'master', @files );
    return QohA::Errors::compare_errors( $ko1, $ko2 );
}
=cut



1;

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
