use Modern::Perl;
use Data::Dumper::Dumper;

# note: this file contains deliberate trailing spaces and tabs

my $line_with_widespace = "bar";     

	my $line_with_tab_character = "berk !";

warn Data::Dumper::Dumper $line_with_tab_character; # we don't want Data::Dumper::Dumper
