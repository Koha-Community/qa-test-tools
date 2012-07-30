package QohA::FileFind;

use Modern::Perl;

use List::MoreUtils qw(uniq);

use QohA::Git;

sub get_template_files {
    my ($cnt) = @_;

    my @rca = QohA::Git::log($cnt);

    my @test_files;
    foreach my $f (@rca) {
        chomp $f;
        next if $f =~ /^\w{7} /;

        next unless $f =~ m{\.tt$};
        push @test_files, $f;
    }
    @test_files = uniq(@test_files);
    return @test_files;

}

sub get_perl_files {
    my ($cnt) = @_;

    my @rca = QohA::Git::log($cnt);

    my @perl_files;
    foreach my $f (@rca) {
        chomp $f;
        next if $f =~ /^\w{7} /;

        next unless $f =~ qr/\.pm$|\.pl$|\.t$/;
        push @perl_files, $f;

    }
    @perl_files = uniq(@perl_files);
    return @perl_files;
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
