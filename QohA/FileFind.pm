package QohA::FileFind;

use Modern::Perl;

use List::MoreUtils qw(uniq);

BEGIN {
  use Exporter (); 
  use vars qw(@ISA @EXPORT @EXPORT_OK);
  @ISA = qw(Exporter);
  @EXPORT_OK = qw(get_test_filelist get_perl_filelist);
}


sub get_test_filelist {
    my ($cnt) = @_;
    my $rc;
    my @rca = qx|git log --oneline  --numstat -$cnt|;
### @rca

    my @hs;
    my @fs;
    foreach my $z (@rca) {
        next if ( $z =~ /^\w{7} / );

        next unless $z =~ /.t$/i;

        my @a = split /\t/, $z;
        push @hs, chomp $a[2];
        push @hs, $a[2];
    }
    @hs = uniq(@hs);
### @hs

    return @hs;

}

sub get_perl_filelist {
    my ($cnt) = @_;
    my $rc;
    my @rca = qx|git log --oneline  --numstat -$cnt|;
### @rca

    my @hs;
    my @fs;
    foreach my $z (@rca) {
        next if ( $z =~ /^\w{7} / );

        next if $z =~ /.tt$/;
        next unless $z =~ qr/\.pm$|\.pl$|\.t$/;

        my @a = split /\t/, $z;
### @a
        chomp $a[2];
        push @hs,  $a[2];
    }
    @hs = uniq(@hs);
### @hs
    return @hs;

}


1;
