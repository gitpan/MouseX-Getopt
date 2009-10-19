package MouseX::Getopt::Meta::Attribute::Trait::NoGetopt;
use Mouse::Role;

no Mouse::Role;

# register this as a metaclass alias ...
package # stop confusing PAUSE
    Mouse::Meta::Attribute::Custom::Trait::NoGetopt;
sub register_implementation { 'MouseX::Getopt::Meta::Attribute::Trait::NoGetopt' }

1;

__END__

=pod

=head1 NAME

MouseX::Getopt::Meta::Attribute::Trait::NoGetopt - Optional meta attribute trait for ignoring params

=head1 SYNOPSIS

  package App;
  use Mouse;
  
  with 'MouseX::Getopt';
  
  has 'data' => (
      traits  => [ 'NoGetopt' ],  # do not attempt to capture this param  
      is      => 'ro',
      isa     => 'Str',
      default => 'file.dat',
  );

=head1 DESCRIPTION

This is a custom attribute metaclass trait which can be used to 
specify that a specific attribute should B<not> be processed by 
C<MouseX::Getopt>. All you need to do is specify the C<NoGetopt> 
metaclass trait.

  has 'foo' => (traits => [ 'NoGetopt', ... ], ... );

=head1 METHODS

=over 4

=item B<meta>

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


