use Modern::Perl;

my $input;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "my/template.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {},
                 debug => 1,
});

sub get_template_and_user {
    return;
}
