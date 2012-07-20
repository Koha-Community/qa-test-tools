package QohA::Git;

use Modern::Perl;

BEGIN {
    use Exporter (); 
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(
        log
        create_and_change_branch
        change_branch
        delete_branch
        reset_hard
        get_current_branch
    );
}

sub log {
    my ( $cnt ) = @_;
    return qx|git log --oneline  --numstat -$cnt|;
}

sub create_and_change_branch {
    my ( $branchname ) = @_;
    qx|git checkout -b $branchname 2> /dev/null|;
}

sub change_branch {
    my ( $branchname ) = @_;
    qx|git checkout $branchname 2> /dev/null|;
}

sub delete_branch {
    my ( $branchname ) = @_;
    qx|git branch -D $branchname 2> /dev/null|;
}

sub reset_hard {
    my ( $cnt ) = @_;
    qx|git reset --hard HEAD~$cnt 2> /dev/null|;
}

#FIXME There is no a simple way to get the 
sub get_current_branch {
    my $br = qx/git branch|grep '*'/;
    $br =~ s/\* //g;
    chomp $br;
    return $br;
}


1;
