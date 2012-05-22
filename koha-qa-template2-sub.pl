#!/usr/bin/perl -w

use Modern::Perl;

#use Smart::Comments;
use List::Compare;

use File::Find;
use File::Spec;
use Template;
use Test::More;

# use FindBin;

### @ARGV

foreach my $f (@ARGV) {

    #calc tmpl and inc paths
    my $template_dir;
    my $include_dir;

    if ( $f =~ /opac-tmpl/ ) {
        $template_dir =
          File::Spec->rel2abs("koha-tmpl/opac-tmpl/prog/en/modules");
        $include_dir =
          File::Spec->rel2abs("koha-tmpl/opac-tmpl/prog/en/includes");

    }
    else {

        $template_dir =
          File::Spec->rel2abs("koha-tmpl/intranet-tmpl/prog/en/modules");
        $include_dir =
          File::Spec->rel2abs("koha-tmpl/intranet-tmpl/prog/en/includes");

    }

    my $tt = Template->new(
        {
            ABSOLUTE     => 1,
            INCLUDE_PATH => $include_dir,
            PLUGIN_BASE  => 'Koha::Template::Plugin',
        }
    );
    my $vars;
    my $output;

### $f

    $f = File::Spec->rel2abs($f);
### $f

    if ( !ok( $tt->process( $f, $vars, \$output ), $f ) ) {
        warn "FAIL";
        my $e1 = diag( $tt->error );
    }

}

done_testing()

