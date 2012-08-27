use Modern::Perl;
use Test::More;

use QohA::Git;
use QohA::Files;

my $git = QohA::Git->new();
our $branch = $git->branchname;

my $num_of_commits = 1;
my $v = 1;
my $stash=qx|git stash|;
my $want_stash_pop = 0;
if ( $stash =~ /Saved working directory and index state/){
    $want_stash_pop = 1;
}
eval {
    $git->change_branch('t');
    my $modified_files = QohA::Files->new( { files => $git->log($num_of_commits) } );
    $git->delete_branch( 'qa-prev-commit_t' );
    $git->create_and_change_branch( 'qa-prev-commit_t' );
    $git->reset_hard_prev( $num_of_commits );

    my @perl_files = $modified_files->filter('perl');
    my @tt_files = $modified_files->filter('tt');
    my @xml_files = $modified_files->filter('xml');
    for my $f ( @perl_files, @tt_files, @xml_files ) {
        $f->run_checks();
    }

    $git->change_branch('t');
    $git->delete_branch( 'qa-current-commit_t' );
    $git->create_and_change_branch( 'qa-current-commit_t' );
    for my $f ( @perl_files, @tt_files, @xml_files ) {
        $f->run_checks($num_of_commits);
    }

    my ($perl_fail_compil) = grep {$_->path eq qq{t/data/perl/i_fail_compil.pl}} @perl_files;
    is( ref $perl_fail_compil, qq{QohA::File::Perl}, "i_fail_compil.pl found" );
    my ($fail_compil_before, $fail_compil_after) = @{ $perl_fail_compil->report->tasks->{valid} };
    is( $fail_compil_before, 1, "fail_compil passed compil before" );
    is( scalar @$fail_compil_after, 1, "fail_compil has 1 error for compil now");
    is( @$fail_compil_after[0] =~ m{Can't locate Foo/Bar.pm}, 1, qq{the compil error for fail_compil is "can't locate Foo/Bar.pm} );

    my ($perl_fail_critic) = grep {$_->path eq qq{t/data/perl/i_fail_critic.pl}} @perl_files;
    is( ref $perl_fail_critic, qq{QohA::File::Perl}, "i_fail_critic.pl found" );
    my ($fail_critic_before, $fail_critic_after) = @{ $perl_fail_critic->report->tasks->{valid} };
    is( $fail_critic_before, 1, "fail_critic passed valid before");
    is( $fail_critic_after, 1, "fail_critic passes valid now");
    ($fail_critic_before, $fail_critic_after) = @{ $perl_fail_critic->report->tasks->{critic} };
    is($fail_critic_before, 0, "fail_critic passes critic before (file did not exist)");
    is( @$fail_critic_after[0] =~ m{^Bareword file handle.*PBP.$}, 1, qq{the perl critic error for fail_compil is "'Bareword file handle opened[...]See pages 202,204 of PBP.'"} );

    my ($perl_ok) = grep {$_->path eq qq{t/data/perl/i_m_ok.pl}} @perl_files;
    is( ref $perl_ok, qq{QohA::File::Perl}, "i_m_ok.pl found" );


    # Check output result for verbosity = 0 or 1
    # Verbosity = 2 return too many specifics errors to test
    my $RED = "\e[1;31m";
    my $GREEN = "\e[1;32m";
    my $END = "\e[0m";
    our $STATUS_KO = "${RED}FAIL${END}";
    our $STATUS_OK = "${GREEN}OK${END}";
    my $r_v0_expected = <<EOL;
* t/data/perl/i_fail_compil.pl                                             $STATUS_KO
* t/data/perl/i_fail_critic.pl                                             $STATUS_KO
* t/data/perl/i_m_ok.pl                                                    $STATUS_OK
EOL
    my $r_v1_expected = <<EOL;
* t/data/perl/i_fail_compil.pl                                             $STATUS_KO
	forbidden patterns          $STATUS_OK
	valid                       $STATUS_KO
	critic                      $STATUS_OK
* t/data/perl/i_fail_critic.pl                                             $STATUS_KO
	forbidden patterns          $STATUS_OK
	valid                       $STATUS_OK
	critic                      $STATUS_KO
* t/data/perl/i_m_ok.pl                                                    $STATUS_OK
	forbidden patterns          $STATUS_OK
	valid                       $STATUS_OK
	critic                      $STATUS_OK
EOL

    my ( $r_v0, $r_v1 );
    for my $f ( @perl_files, @tt_files, @xml_files ) {
        $r_v0 .= $f->report->to_string(0)."\n";
        $r_v1 .= $f->report->to_string(1)."\n";
    }
    is( $r_v0, $r_v0_expected, "Check verbosity output (0)");
    is( $r_v1, $r_v1_expected, "Check verbosity output (1)");
};
if ($@) {
    warn  "\n\nAn error occured : $@";
}

$git->change_branch($branch);
qx|git stash pop| if $want_stash_pop;

done_testing;
