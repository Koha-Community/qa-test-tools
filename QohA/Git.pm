package QohA::Git;

use Modern::Perl;

sub log {
    my ($cnt) = @_;
    return qx|git log --oneline --numstat --name-only -$cnt|;
}

sub log_as_string {
    my ($cnt) = @_;
    my @logs = QohA::Git::log($cnt);

    my $r;
    foreach my $l (@logs) {
        chomp $l;
        if ( $l =~ /^\w{7} / ) {
            $r .= "\t* $l\n";
        }
        else {
            $r .= "\t\t$l\n";
        }
    }
    $r;
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

sub reset_hard {
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

1;

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
