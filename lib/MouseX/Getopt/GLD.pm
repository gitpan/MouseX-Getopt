package MouseX::Getopt::GLD;

use Mouse::Role;

around '_getopt_spec' => sub {
    my $orig = shift;
    my $self = shift;

    return $self->_gld_spec(@_);
    # Ignore $orig, code for _gld_spec here
};

around '_get_options' => sub {
    my $orig = shift;
    my $class = shift;

    my ($params, $opt_spec) = @_;
    return Getopt::Long::Descriptive::describe_options(
        $class->_usage_format(%$params), @$opt_spec
    );
};


sub _gld_spec {
    my ( $class, %params ) = @_;

    my ( @options, %name_to_init_arg );

    my $constructor_params = $params{params};

    foreach my $opt ( @{ $params{options} } ) {
        push @options, [
            $opt->{opt_string},
            $opt->{doc} || ' ', # FIXME new GLD shouldn't need this hack
            {
                ( ( $opt->{required} && !exists($constructor_params->{$opt->{init_arg}}) ) ? (required => $opt->{required}) : () ),
                # NOTE:
                # remove this 'feature' because it didn't work 
                # all the time, and so is better to not bother
                # since Mouse will handle the defaults just 
                # fine anyway.
                # - SL
                #( exists $opt->{default}  ? (default  => $opt->{default})  : () ),
            },
        ];

        my $identifier = $opt->{name};
        $identifier =~ s/\W/_/g; # Getopt::Long does this to all option names

        $name_to_init_arg{$identifier} = $opt->{init_arg};
    }

    return ( \@options, \%name_to_init_arg );
}

no Mouse::Role;
1;

__END__

=pod

=head1 NAME

MouseX::Getopt::GLD - role to implement specific functionality for 
L<Getopt::Long::Descriptive>

=head1 SYNOPSIS
    
For internal use.

=head1 DESCRIPTION

This is a role for C<MouseX::Getopt>.

=head1 METHODS

=over 4

=item meta

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

FUJI Goro E<lt>gfuji@cpan.orgE<gt> from 0.22

=head1 OROGINAL AUTHOR

See L<MooseX::Getopt/AUTHOR> and L<MooseX::Getopt/CONTRIBUTORS>.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
