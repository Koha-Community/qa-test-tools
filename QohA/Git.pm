package QohA::Git;

use Modern::Perl;
use Smart::Comments  -ENV;

use Moo;

has 'branchname' => (
    is => 'rw',
    default => sub{ get_current_branch() },
);

# this sub returns all modified files, for testing on
# and ignores deleted or moved files
sub log {
    my ($self, $cnt) = @_;

    #skip deleted files..
    my @r = qx{git log --oneline --numstat  --diff-filter='ACMRTUXB' -$cnt};
    my @r1;

    # oops, lets strip out deleted or moved files, from selection
    foreach my $rr ( @r ) {
        chomp $rr;
        my @cols = split '\t', $rr ;

        # ignore lines that are commit shas, not filename
        next if not defined $cols[2];
        push @r1, $cols[2];
    }
#### @r1

    return \@r1 ;
}

sub diff_log {
    my ($self, $cnt, $file) = @_; # $file is optionnal
    my $cmd = qq{git diff HEAD~$cnt..};
    $cmd .= qq{ $file} if $file;
    my @r = qx/$cmd/;
    chomp for @r;
    return \@r;
}

sub log_as_string {
    my ($cnt) = @_;
    my @logs = qx{git log --oneline --numstat -$cnt};

#### @logs

    my $cc = get_prev_commit($cnt);

    my $r;
    my $i = 0;
    foreach my $l (@logs) {
        chomp $l;


        my @a = split '\t', $l;
        my ($sha, $diff, $action, $filename);

        if ( $a[0] =~ /^\w{7} / and not defined $a[2] ) {
            $sha = $a[0];
            $filename = $a[1];
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

            $r .= "      $filename";

        }
        $r .= "\n";
        $i++;
    }
    return "$r\n";
}

sub create_and_change_branch {
    my ($self, $branchname) = @_;
    qx|git checkout -b $branchname 2> /dev/null|;
}

sub change_branch {
    my ($self, $branchname) = @_;
    qx|git checkout $branchname 2> /dev/null|;
}

sub delete_branch {
    my ($self, $branchname) = @_;
    qx|git branch -D $branchname 2> /dev/null|;
}

sub reset_hard_prev {
    my ($self, $cnt) = @_;
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
    my ($cnt) = @_;
    my $cc =
      qx{git log --abbrev-commit --format=oneline -n 1 HEAD~$cnt};
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
