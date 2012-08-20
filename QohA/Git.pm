package QohA::Git;

use Modern::Perl;
#use Smart::Comments;

# this sub returns all modified files, for testing on
# and ignores deleted or moved files
sub log {
    my ($cnt) = @_;

    my @r = qx/git log --oneline --numstat  -$cnt/;
    my @r1;

#### 'aaaaaaa'

    # oops, lets strip out deleted or moved files, from selection
    foreach ( @r ) {

        my @cols = split '\t' ;

        # ignore lines that are commit shas, not filename
        # ## @cols
        next  if not defined $cols[2];

        # ignore lines that are moved or deleted
        next  if $cols[0] =~ /^0|^-/;
        push @r1, $cols[2];
    }
# ## @r1

return \@r1 ;
}

sub log_as_string {
    my ($cnt) = @_;
    #my @logs = QohA::Git::log($cnt);
    my @logs = qx/git log --oneline --numstat  -$cnt/;


    my $cc = get_prev_commit();

    #warn $cc;

    my $r;
    my $i = 0;
    foreach my $l (@logs) {
        chomp $l;


        my @a = split '\t', $l;
        my ($sha, $diff, $filename);

        if ( $a[0] =~ /^\w{7} / and not defined $a[2] ) {
            $sha = $a[0];
        } else {
            $diff = $a[0];
            $filename = $a[2];
        }

        # if its a commit lines
        if ($sha) {

            $r .= "testing $cnt commit(s) (applied to commit $cc)" if $i == 0;

            $l = substr $a[0], 0, 70;
            $r .= "\n * $a[0]";

        }
        else {

            #next if lines is deleted or removed
            next if $diff =~ /^0|^\-/;
            $r .= "      $filename";


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
