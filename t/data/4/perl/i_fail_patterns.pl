use Modern::Perl;

use Data::Dumper::Dumper;

my $line_with_widespace = "bar";     

	my $line_with_tab_character = "berk !"

warn Data::Dumper::Dumper $line_with_tab_character; # we don't want Data::Dumper::Dumper
