package QohA::Template;

use Modern::Perl;
use IPC::Cmd qw[can_run run];
use File::Spec;

use Template;
use Data::Dumper;

no strict 'refs';

use QohA::FileFind;
use QohA::Git;
use QohA::Errors;

use Smart::Comments  -ENV, '####';

BEGIN {
    use Exporter ();
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
      valid
    );
}

sub init_tests {
#### 'init_tests'

    my ( $commits, $test_name, $file_type ) = @_;

#### $commits
#### $test_name
#### $file_type

    my @files = QohA::FileFind::get_files( $commits, $file_type );
#### @files

    #if no files have changed, then no need to do any tests!
    return ( 'OK', undef ) unless @files;

    QohA::Git::delete_branch('qa-current-commit');
    QohA::Git::create_and_change_branch('qa-current-commit');
    my $new_errs = run_test( $test_name, \@files );

#### $new_errs
    #if no new errors, then no need to run any comparison tests against the previous commits
    return ( 'OK', undef ) unless $new_errs;

    QohA::Git::delete_branch('qa-prev-commit');
    QohA::Git::create_and_change_branch('qa-prev-commit');
    QohA::Git::reset_hard_prev($commits);
    my $existing_errs = run_test( $test_name, \@files );
#### $existing_errs

    QohA::Git::change_branch($main::br);
    $new_errs = QohA::Errors::compare_errors( $existing_errs, $new_errs );
    my ( $rc, $full ) = QohA::Errors::display_with_files($new_errs);

    return ( $rc, $full );

}

sub run_test {
    my $test_name = shift;
    my $files     = shift;


    my $errs;

    if ( $test_name eq 'xml_valid' ) {
        $errs = QohA::Template::xml_valid();
    }

    elsif ( $test_name eq 'tt_valid' ) {
        $errs = QohA::Template::tt_valid();
    }

    elsif ( $test_name eq 'valid_templates' ) {
        $errs = QohA::Template::valid_templates($files);
    }

    elsif ( $test_name eq 'perlcritic_valid' ) {
        $errs = QohA::Perl::valid_templates($files);
    }

    elsif ( $test_name eq 'perl_valid' ) {
        $errs = QohA::Template::perl_valid($files);
    }

    return ($errs);

}

sub perl_valid {

    my ($files) = @_;
    my @err;
    foreach my $f (@$files) {
        my $rs = qx |perl -cw $f 2>&1  |;
        push @err, $rs;
    }
    #### @err
    return \@err;
}

sub xml_valid {

    my $cmd = "prove ./t/00-valid-xml.t  2>&1 ";
    my @aa = run( command => $cmd, verbose => 0 );

    my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
      run( command => $cmd, verbose => 0 );

    my @errs;
    for my $buf (@$full_buf) {
        for my $line ( split '\n', $buf ) {
            next unless $line;
            if ( $line =~ m/parser error/ ) {
                push @errs, $line;
            }
        }
    }
    return \@errs;
}

sub tt_valid {
    my $cmd = " prove ./xt/tt_valid.t 1> /dev/null ";

    my @qq = run( command => $cmd, verbose => 0 );

    my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
      run( command => $cmd, verbose => 0 );

    my @errs;
    for my $buf (@$full_buf) {
        for my $line ( split '\n', $buf ) {
            next unless $line;
            if ( $line =~ m/^# (.*.tt): (.*)$/ ) {
                push @errs, "$1: $2";
            }
        }
    }

    return \@errs;
}

sub valid_templates {
    my ($files) = @_;
    my @errors;
    foreach my $f (@$files) {

        my $template_dir;
        my $include_dir;

        my $tmpl_type =
          $f =~ /opac-tmpl/
          ? 'opac'
          : 'intranet';
        $template_dir =
          File::Spec->rel2abs("koha-tmpl/${tmpl_type}-tmpl/prog/en/modules");
        $include_dir =
          File::Spec->rel2abs("koha-tmpl/${tmpl_type}-tmpl/prog/en/includes");

        my $tt = Template->new(
            {
                ABSOLUTE     => 1,
                INCLUDE_PATH => $include_dir,
                PLUGIN_BASE  => 'Koha::Template::Plugin',
            }
        );

        my $vars;
        my $output;
        my $absf = File::Spec->rel2abs($f);

        my $ok = $tt->process( $absf, $vars, \$output );
        unless ($ok) {
            my $z = $tt->error();

            push @errors, $z->info() . "\n";
            #### $z
        }

    }

    return \@errors;
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
