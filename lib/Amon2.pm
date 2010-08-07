package Amon2;
use strict;
use warnings;
use 5.008001;
use UNIVERSAL::require;
use Amon2::Util;
use Plack::Util ();

our $VERSION = '0.44';
{
    our $_context;
    sub context { $_context }
    sub set_context { $_context = $_[1] }
}

sub import {
    my $class = shift;

    strict->import;
    warnings->import;

    if (@_>0 && shift eq '-base') {
        my $caller = caller(0);
        my %args = @_;

        no strict 'refs';
        unshift @{"${caller}::ISA"}, 'Amon2::Base';

        my $base_dir = Amon2::Util::base_dir($caller);
        *{"${caller}::base_dir"} = sub { $base_dir };

        *{"${caller}::base_name"} = sub { $caller };
    }
}

package Amon2::Base;
use Data::OptList;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless { config => +{}, %args }, $class;
}

sub config { $_[0]->{config} }

# for CLI
sub bootstrap {
    my $class = shift;
    my $self = $class->new(@_);
    Amon2->set_context($self);
    return $self;
}

# -------------------------------------------------------------------------
# pluggable things

sub load_plugins {
    my ($class, @args) = @_;
    for my $opt (@{Data::OptList::mkopt(\@args)}) {
        my ($module, $conf) = ($opt->[0], $opt->[1]);
        $class->load_plugin($module, $conf);
    }
}

sub load_plugin {
    my ($class, $module, $conf) = @_;
    $module = Plack::Util::load_class($module, 'Amon2::Plugin');
    $module->init($class, $conf);
}


1;
__END__

=head1 NAME

Amon2 - lightweight web application framework

=head1 SYNOPSIS

    $ amon-setup.pl MyApp

=head1 Point

    Fast
    Easy to use

=head1 CLASS METHODS

=over 4

=item my $c = Amon2->context();

Get the context object.

=item Amon2->set_context($c)

Set your context object(INTERNAL USE ONLY).

=back

=head1 AUTHOR

Tokuhiro Matsuno

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
