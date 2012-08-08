package QohA::Template;

use Modern::Perl;
use IPC::Cmd qw[can_run run];
use File::Spec;
use Template;

use QohA::FileFind;
use QohA::Git;
use QohA::Errors;

BEGIN {
    use Exporter ();
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
      valid
    );
}

sub run_tt_valid {
    my ($cnt) = @_;
    my @files = QohA::FileFind::get_template_files($cnt);

    return unless @files;

    my $br = QohA::Git::get_current_branch();

    QohA::Git::delete_branch('qa1');
    QohA::Git::create_and_change_branch('qa1');
    QohA::Git::reset_hard($cnt);

    my @err1 = QohA::Template::tt_valid();

    QohA::Git::change_branch($br);

    my @err2 = QohA::Template::tt_valid();

    return QohA::Errors::compare_errors( \@err1, \@err2 );

}

sub tt_valid {
    my $cmd = " prove ./xt/tt_valid.t 1> /dev/null ";

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

    return @errs;
}

sub run_xt_valid_templates {
    my ($cnt) = @_;

    my @files = QohA::FileFind::get_template_files($cnt);
    return unless @files;

    my $br = QohA::Git::get_current_branch();

    QohA::Git::delete_branch('qa1');
    QohA::Git::create_and_change_branch('qa1');
    QohA::Git::reset_hard($cnt);

    my @err1 = valid_templates( \@files );

    QohA::Git::change_branch($br);

    my @err2 = valid_templates( \@files );

    my $lc;

    return QohA::Errors::compare_errors( \@err1, \@err2 );
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
            push @errors, $f;
        }
    }
    return @errors;
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
