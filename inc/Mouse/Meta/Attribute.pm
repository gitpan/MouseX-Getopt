#line 1
package Mouse::Meta::Attribute;
use strict;
use warnings;
require overload;

use Carp 'confess';
use Scalar::Util ();
use Mouse::Meta::TypeConstraint;
use Mouse::Meta::Method::Accessor;

sub new {
    my ($class, $name, %options) = @_;

    $options{name} = $name;

    $options{init_arg} = $name
        unless exists $options{init_arg};

    $options{is} ||= '';

    bless \%options, $class;
}

sub name                 { $_[0]->{name}                   }
sub associated_class     { $_[0]->{associated_class}       }
sub _is_metadata         { $_[0]->{is}                     }
sub is_required          { $_[0]->{required}               }
sub default              { $_[0]->{default}                }
sub is_lazy              { $_[0]->{lazy}                   }
sub is_lazy_build        { $_[0]->{lazy_build}             }
sub predicate            { $_[0]->{predicate}              }
sub clearer              { $_[0]->{clearer}                }
sub handles              { $_[0]->{handles}                }
sub is_weak_ref          { $_[0]->{weak_ref}               }
sub init_arg             { $_[0]->{init_arg}               }
sub type_constraint      { $_[0]->{type_constraint}        }
sub find_type_constraint {
    Carp::carp("This method was deprecated");
    $_[0]->type_constraint();
}
sub trigger              { $_[0]->{trigger}                }
sub builder              { $_[0]->{builder}                }
sub should_auto_deref    { $_[0]->{auto_deref}             }
sub should_coerce        { $_[0]->{should_coerce}          }

sub has_default          { exists $_[0]->{default}         }
sub has_predicate        { exists $_[0]->{predicate}       }
sub has_clearer          { exists $_[0]->{clearer}         }
sub has_handles          { exists $_[0]->{handles}         }
sub has_type_constraint  { exists $_[0]->{type_constraint} }
sub has_trigger          { exists $_[0]->{trigger}         }
sub has_builder          { exists $_[0]->{builder}         }

sub _create_args {
    $_[0]->{_create_args} = $_[1] if @_ > 1;
    $_[0]->{_create_args}
}

sub inlined_name {
    my $self = shift;
    my $name = $self->name;
    my $key   = "'" . $name . "'";
    return $key;
}

sub generate_predicate {
    my $attribute = shift;
    my $key = $attribute->inlined_name;

    my $predicate = 'sub { exists($_[0]->{'.$key.'}) }';

    my $sub = eval $predicate;
    confess $@ if $@;
    return $sub;
}

sub generate_clearer {
    my $attribute = shift;
    my $key = $attribute->inlined_name;

    my $clearer = 'sub { delete($_[0]->{'.$key.'}) }';

    my $sub = eval $clearer;
    confess $@ if $@;
    return $sub;
}

sub generate_handles {
    my $attribute = shift;
    my $reader = $attribute->name;
    my %handles = $attribute->_canonicalize_handles($attribute->handles);

    my %method_map;

    for my $local_method (keys %handles) {
        my $remote_method = $handles{$local_method};

        my $method = 'sub {
            my $self = shift;
            $self->'.$reader.'->'.$remote_method.'(@_)
        }';

        $method_map{$local_method} = eval $method;
        confess $@ if $@;
    }

    return \%method_map;
}

sub create {
    my ($self, $class, $name, %args) = @_;

    $args{name} = $name;
    $args{associated_class} = $class;

    %args = $self->canonicalize_args($name, %args);
    $self->validate_args($name, \%args);

    $args{should_coerce} = delete $args{coerce}
        if exists $args{coerce};

    if (exists $args{isa}) {
        confess "Got isa => $args{isa}, but Mouse does not yet support parameterized types for containers other than ArrayRef and HashRef (rt.cpan.org #39795)"
            if $args{isa} =~ /^([^\[]+)\[.+\]$/ &&
               $1 ne 'ArrayRef' &&
               $1 ne 'HashRef'  &&
               $1 ne 'Maybe'
        ;

        my $type_constraint = delete $args{isa};
        $args{type_constraint}= Mouse::Util::TypeConstraints::find_or_create_isa_type_constraint($type_constraint);
    }

    my $attribute = $self->new($name, %args);

    $attribute->_create_args(\%args);

    $class->add_attribute($attribute);

    # install an accessor
    if ($attribute->_is_metadata eq 'rw' || $attribute->_is_metadata eq 'ro') {
        my $code = Mouse::Meta::Method::Accessor->generate_accessor_method_inline(
            $attribute,
        );
        $class->add_method($name => $code);
    }

    for my $method (qw/predicate clearer/) {
        my $predicate = "has_$method";
        if ($attribute->$predicate) {
            my $generator = "generate_$method";
            my $coderef = $attribute->$generator;
            $class->add_method($attribute->$method => $coderef);
        }
    }

    if ($attribute->has_handles) {
        my $method_map = $attribute->generate_handles;
        for my $method_name (keys %$method_map) {
            $class->add_method($method_name => $method_map->{$method_name});
        }
    }

    return $attribute;
}

sub canonicalize_args {
    my $self = shift;
    my $name = shift;
    my %args = @_;

    if ($args{lazy_build}) {
        $args{lazy}      = 1;
        $args{required}  = 1;
        $args{builder}   = "_build_${name}"
            if !exists($args{builder});
        if ($name =~ /^_/) {
            $args{clearer}   = "_clear${name}" if !exists($args{clearer});
            $args{predicate} = "_has${name}" if !exists($args{predicate});
        }
        else {
            $args{clearer}   = "clear_${name}" if !exists($args{clearer});
            $args{predicate} = "has_${name}" if !exists($args{predicate});
        }
    }

    return %args;
}

sub validate_args {
    my $self = shift;
    my $name = shift;
    my $args = shift;

    confess "You can not use lazy_build and default for the same attribute ($name)"
        if $args->{lazy_build} && exists $args->{default};

    confess "You cannot have lazy attribute ($name) without specifying a default value for it"
        if $args->{lazy}
        && !exists($args->{default})
        && !exists($args->{builder});

    confess "References are not allowed as default values, you must wrap the default of '$name' in a CODE reference (ex: sub { [] } and not [])"
        if ref($args->{default})
        && ref($args->{default}) ne 'CODE';

    confess "You cannot auto-dereference without specifying a type constraint on attribute ($name)"
        if $args->{auto_deref} && !exists($args->{isa});

    confess "You cannot auto-dereference anything other than a ArrayRef or HashRef on attribute ($name)"
        if $args->{auto_deref}
        && $args->{isa} ne 'ArrayRef'
        && $args->{isa} ne 'HashRef';

    if ($args->{trigger}) {
        if (ref($args->{trigger}) eq 'HASH') {
            Carp::carp "HASH-based form of trigger has been removed. Only the coderef form of triggers are now supported.";
        }

        confess "Trigger must be a CODE ref on attribute ($name)"
            if ref($args->{trigger}) ne 'CODE';
    }

    return 1;
}

sub verify_against_type_constraint {
    return 1 unless $_[0]->{type_constraint};

    local $_ = $_[1];
    return 1 if $_[0]->{type_constraint}->check($_);

    my $self = shift;
    $self->verify_type_constraint_error($self->name, $_, $self->{type_constraint});
}

sub verify_type_constraint_error {
    my($self, $name, $value, $type) = @_;
    $type = ref($type) eq 'ARRAY' ? join '|', map { $_->name } @{ $type } : $type->name;
    my $display = defined($value) ? overload::StrVal($value) : 'undef';
    Carp::confess("Attribute ($name) does not pass the type constraint because: Validation failed for \'$type\' failed with value $display");
}

sub coerce_constraint { ## my($self, $value) = @_;
    my $type = $_[0]->{type_constraint}
        or return $_[1];
    return Mouse::Util::TypeConstraints->typecast_constraints($_[0]->associated_class->name, $_[0]->type_constraint, $_[1]);
}

sub _canonicalize_handles {
    my $self    = shift;
    my $handles = shift;

    if (ref($handles) eq 'HASH') {
        return %$handles;
    }
    elsif (ref($handles) eq 'ARRAY') {
        return map { $_ => $_ } @$handles;
    }
    else {
        confess "Unable to canonicalize the 'handles' option with $handles";
    }
}

sub clone_parent {
    my $self  = shift;
    my $class = shift;
    my $name  = shift;
    my %args  = ($self->get_parent_args($class, $name), @_);

    $self->create($class, $name, %args);
}

sub get_parent_args {
    my $self  = shift;
    my $class = shift;
    my $name  = shift;

    for my $super ($class->linearized_isa) {
        my $super_attr = $super->can("meta") && $super->meta->get_attribute($name)
            or next;
        return %{ $super_attr->_create_args };
    }

    confess "Could not find an attribute by the name of '$name' to inherit from";
}

1;

__END__

#line 394

