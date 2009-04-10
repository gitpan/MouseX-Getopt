#line 1
package Mouse::Meta::TypeConstraint;
use strict;
use warnings;
use overload '""'     => sub { shift->{name} },   # stringify to tc name
             fallback => 1;

sub new {
    my $class = shift;
    my %args = @_;
    my $name = $args{name} || '__ANON__';

    my $check = $args{_compiled_type_constraint} or Carp::croak("missing _compiled_type_constraint");
    if (ref $check eq 'Mouse::Meta::TypeConstraint') {
        $check = $check->{_compiled_type_constraint};
    }

    bless +{ name => $name, _compiled_type_constraint => $check }, $class;
}

sub name { shift->{name} }

sub check {
    my $self = shift;
    $self->{_compiled_type_constraint}->(@_);
}

1;
__END__

#line 54

