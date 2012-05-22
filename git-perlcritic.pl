use Modern::Perl;
use Perl::Critic;
use Smart::Comments '####';

=c
die "No file name as argument\n" if (@ARGV == 0);
my $file = $ARGV[0];

my $critic = Perl::Critic->new();
my @violations = $critic->critique($file);
print @violations;
=cut

my $rc = `git log --oneline  --stat -1`;

## ## $rc

my @l = split /\n/, $rc;

foreach my $r (@l) {

    chomp $r;

    next unless $r =~ /\|/;
    next unless $r =~ /\+/;

    next unless $r =~ /\.pm|\.pl|\.t/i;

    $r =~ s/\|.*$//;
    $r =~ s/^[ \t]+|[ \t]+$//g;


 next unless (-e $r ) ; 

#print "$r: OK\n";
## ## $r
    my $file = $r;

    my $critic     = Perl::Critic->new();
    my @violations = $critic->critique($file);
    if ( @violations) {
print "$r: @violations\n";
    } else {
print "$r: OK\n";
    }

}
