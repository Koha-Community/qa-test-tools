package QohA::Errors;

use Modern::Perl;

use List::Compare;

#use Smart::Comments;
use Data::Dumper;

sub compare_errors {
    my ( $err1, $err2 ) = @_;

    my $lc = List::Compare->new( '-u', $err2, $err1 );

    my @already_fails = $lc->get_intersection;

    my @new_fails = $lc->get_unique;

    #    return ( \@new_fails, \@already_fails );
    return ( \@new_fails );
}

sub display {
    my ($fails) = @_;
    my $s;
    if ( $fails and @$fails ) {
        $s = " FAIL\n";
        $s .= "\t@$fails" if @$fails;
    }
    else { $s = "OK" }
    return $s;
}

sub display_with_files {
    my ($fails) = @_;
    my ( $s, $full );
    if ( $fails and @$fails ) {
        $s = "FAIL";

        #$s .= "\t$_ FAIL\n" for @$fails;

        if ( $main::v and @$fails ) {
            $full .= "\t$_" for @$fails;
        }

    }
    else { $s = "OK" }

    return ( $s, $full );
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
