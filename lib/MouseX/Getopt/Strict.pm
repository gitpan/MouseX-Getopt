package MouseX::Getopt::Strict;
use Mouse::Role;

with 'MouseX::Getopt';

around '_compute_getopt_attrs' => sub {
    my $next = shift;
    my ( $class, @args ) = @_;
    grep { 
        $_->isa("MouseX::Getopt::Meta::Attribute") 
    } $class->$next(@args);
};

1;

__END__

=pod

=head1 NAME

MouseX::Getopt::Strict - only make options for attrs with the Getopt metaclass
    
=head1 DESCRIPTION

This is an stricter version of C<MouseX::Getopt> which only processes the 
attributes if they explicitly set as C<Getopt> attributes. All other attributes
are ignored by the command line handler.
    
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

This is based on C<MooseX::Getopt>.

L<MooseX::Getopt/AUTHOR> and L<MooseX::Getopt/CONTRIBUTORS> 

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
