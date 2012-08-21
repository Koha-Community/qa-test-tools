package QohA::FileFind;

use Modern::Perl;

use List::MoreUtils qw(uniq);

use QohA::Git;

#use Smart::Comments '###';
#use Data::Dumper;

sub get_files {
    my $commits   = shift;
    my $file_type = shift;



    my @files;
    if ( $file_type eq 'xml' ) {
        @files = QohA::FileFind::get_xml_files($commits);

    }

    elsif ( $file_type eq 'tt' ) {
        @files = QohA::FileFind::get_tt_files($commits);

    }

    elsif ( $file_type eq 'perl' ) {
        @files = QohA::FileFind::get_perl_files($commits);

    }

### 'zzzzzzzzzzzz'
###   @files

    return @files;


}

sub get_xml_files {
    my ($cnt) = shift;

    my @files = QohA::Git::log($cnt);

    my @new_files;
    foreach my $f (@files) {
        chomp $f;
        next unless $f =~ qr/\.xml$|\.xsl$|\.xslt$/i;
        push @new_files, $f;

    }
    @new_files = uniq(@new_files);
    return @new_files;
}

sub get_perl_files {
### 'cccccccccc'
    my ($cnt) = shift;

    my $files = QohA::Git::log($cnt);
# ## $files

    my @new_files;
    foreach my $f (@$files) {
        chomp $f;
        ### $f
        next unless $f =~ qr/\.pl$|\.pm$/i;
        push @new_files, $f;

    }

## # @new_files
    @new_files = uniq(@new_files);
## # @new_files


    return @new_files;
}

sub get_tt_files {
    my ($cnt) = shift;

    my @files = QohA::Git::log($cnt);

    my @new_files;
    foreach my $f (@files) {
        chomp $f;
        next unless $f =~ qr/\.tt$|\.inc$/i;
        push @new_files, $f;

    }
    @new_files = uniq(@new_files);
    return @new_files;
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
