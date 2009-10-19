package MouseX::Getopt::Dashes;
use Mouse::Role;

with 'MouseX::Getopt';

around _get_cmd_flags_for_attr => sub {
    my $next = shift;
    my ( $class, $attr, @rest ) = @_;

    my ( $flag, @aliases ) = $class->$next($attr, @rest);
    $flag =~ tr/_/-/
        unless $attr->does('MouseX::Getopt::Meta::Attribute::Trait')
            && $attr->has_cmd_flag;

    return ( $flag, @aliases );
};

1;

__END__

=pod

=head1 NAME

MouseX::Getopt::Dashes - convert underscores in attribute names to dashes

=head1 SYNOPSIS

  package My::App;
  use Mouse;
  with 'MouseX::Getopt::Dashes';

  # use as MouseX::Getopt

=head1 DESCRIPTION

This is a version of C<MouseX::Getopt> which converts underscores in
attribute names to dashes when generating command line flags.

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
