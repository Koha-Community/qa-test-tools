#!/usr/bin/perl -w

use Modern::Perl;
use Test::Perl::Critic::Progressive ( ':all' );
use Smart::Comments '####';


# ### @ARGV
my $conf = pop @ARGV;
#### $conf

#print $conf;

set_history_file($conf);
progressive_critic_ok(@ARGV);

=head1 AUTHOR
Mason James <mtj at kohaaloha.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by KohaAloha

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007
=cut
