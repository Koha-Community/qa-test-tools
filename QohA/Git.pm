package QohA::Git;

use Modern::Perl;

sub log {
    my ($cnt) = @_;
    return qx|git log --oneline --numstat --name-only -$cnt|;
}

sub log_as_string {
    my ($cnt) = @_;
    my @logs = QohA::Git::log($cnt);

    my $cc = get_prev_commit();

    #warn $cc;

    my $r;
    my $i = 0;
    foreach my $l (@logs) {
        chomp $l;
        if ( $l =~ /^\w{7} / ) {

            $r .= "testing $cnt commit(s) (applied to commit $cc)" unless $i;
            $l = substr $l, 0, 70;
            $r .= "\n * $l";

        }
        else {
            $r .= "      $l";
        }
        $r .= "\n";
        $i++;
    }
    return "$r\n";
}

sub create_and_change_branch {
    my ($branchname) = @_;
    qx|git checkout -b $branchname 2> /dev/null|;
}

sub change_branch {
    my ($branchname) = @_;
    qx|git checkout $branchname 2> /dev/null|;
}

sub delete_branch {
    my ($branchname) = @_;
    qx|git branch -D $branchname 2> /dev/null|;
}

sub reset_hard_prev {
    my ($cnt) = @_;
    qx|git reset --hard HEAD~$cnt 2> /dev/null|;
}

#FIXME There is no a simple way to get the current branch
sub get_current_branch {
    my $br = qx/git branch|grep '*'/;
    $br =~ s/\* //g;
    chomp $br;
    return $br;
}

sub get_prev_commit {
    my $num_of_commits = $main::num_of_commits;
    my $cc =
      qx/git log --abbrev-commit  --format=oneline -n 1 HEAD~$num_of_commits /;
    $cc =~ s/ .*//;

    chomp $cc;
    return $cc;

}

1;

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
