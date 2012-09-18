package QohA::File::Template;

use Modern::Perl;
use Moo;

extends 'QohA::File';

use IPC::Cmd qw[can_run run];
use File::Spec;

use QohA::Report;
use C4::TTParser;
use Template;

has 'pass' => (
    is => 'rw',
    default => sub{1},
);

has 'report' => (
    is => 'rw',
    default => sub {
        QohA::Report->new( {type => 'template'} );
    },
);

sub run_checks {
    my ($self, $cnt) = @_;
    my $r;
    $r = $self->check_tt_valid();
    $self->report->add(
        {
            file => $self,
            name => 'tt_valid',
            error => ( $r ? $r : '' ),
        }
    );

    $r = $self->check_valid_template();
    $self->report->add(
        {
            file => $self,
            name => 'valid_template',
            error => ( $r ? $r : '' ),
        }
    );

    if ( $self->pass == 1 ) {
        $self->report->add(
            {
                file => $self,
                name => 'forbidden patterns',
                error => ''
            }
        );
    } else {
        $r = $self->check_forbidden_patterns($cnt);
        $self->report->add(
            {
                file => $self,
                name => 'forbidden patterns',
                error => ( $r ? $r : '' ),
            }
        );
    }

    $self->pass($self->pass + 1);
}

sub check_tt_valid {
    my ($self) = @_;
    return q{} unless -e $self->path;
    my $parser = C4::TTParser->new;
    my $filename = $self->abspath;
    $parser->build_tokens( $filename );
    my @lines;
    my @files;
    while ( my $token = $parser->next_token ) {
        my $attr = $token->{_attr};
        next unless $attr;
        push @lines, $token->{_lc} if $attr->{'[%'};
    }
    return @lines
        ? "lines " . join ', ', @lines
        : "";
}

sub check_valid_template {
    my ($self) = @_;
    return q{} unless -e $self->path;
    my @errors;

    my $template_dir;
    my $include_dir;

    my $tmpl_type =
      $self->path =~ /opac-tmpl/
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
    my $absf = File::Spec->rel2abs($self->path);

    my $ok = $tt->process( $absf, $vars, \$output );
    unless ($ok) {
        my $z = $tt->error();

        push @errors, $z->info();
    }

    return "@errors";
}

sub check_forbidden_patterns {
    my ($self, $cnt) = @_;

    my @forbidden_patterns = (
        {pattern => qr{console.log}, error => "console.log"},
    );

    my $errors = $self->SUPER::check_forbidden_patterns($cnt, \@forbidden_patterns);
    return q{} if $errors == 1;
    return $errors;
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
