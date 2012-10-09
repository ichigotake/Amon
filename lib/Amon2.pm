package Amon2;
use strict;
use warnings;
use 5.008001;
use Amon2::Util ();
use Plack::Util ();
use Carp ();
use Amon2::Config::Simple;

our $VERSION = '3.56';
{
    our $CONTEXT; # You can localize this variable in your application.
    sub context { $CONTEXT }
    sub set_context { $CONTEXT = $_[1] }
}

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless { %args }, $class;
}

# for CLI
sub bootstrap {
    my $class = shift;
    my $self = $class->new(@_);
    Amon2->set_context($self);
    return $self;
}

# class method.
sub base_dir {
    my $proto = ref $_[0] || $_[0];
    my $base_dir = Amon2::Util::base_dir($proto);
    Amon2::Util::add_method($proto, 'base_dir', sub { $base_dir });
    $base_dir;
}

sub load_config { Amon2::Config::Simple->load(shift) }
sub config {
    my $class = shift;
       $class = ref $class || $class;
    die "Do not call Amon2->config() directly." if __PACKAGE__ eq $class;
    no strict 'refs';
    my $config = $class->load_config();
    *{"$class\::config"} = sub { $config }; # class cache.
    return $config;
}

sub mode_name { $ENV{PLACK_ENV} }

sub add_config {
    my ($class, $key, $hash) = @_; $hash or Carp::croak("missing args: \$hash");
    Carp::cluck("Amon2->add_config() method was deprecated.");

    # This method will be deprecate.
    $class->config->{$key} = +{
        %{$class->config->{$key} || +{}},
        %{$hash},
    };
}

# -------------------------------------------------------------------------
# pluggable things

sub load_plugins {
    my ($class, @args) = @_;
    while (@args) {
        my $module = shift @args;
        my $conf   = @args>0 && ref($args[0]) eq 'HASH' ? shift @args : undef;
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

=encoding utf-8

=head1 NAME

Amon2 - lightweight web application framework

=head1 SYNOPSIS

    package MyApp;
    use parent qw/Amon2/;
    use Amon2::Config::Simple;
    sub load_config { Amon2::Config::Simple->load(shift) }

=head1 DESCRIPTION

Amon2 is simple, readable, extensible, B<STABLE>, B<FAST> web application framework based on L<Plack>.

=head1 METHODS

=head2 CLASS METHODS for C<<Amon2>> class

=over 4

=item my $c = Amon2->context();

Get the context object.

=item Amon2->set_context($c)

Set your context object(INTERNAL USE ONLY).

=back

=head1 CLASS METHODS for inherited class

=over 4

=item MyApp->config()

This method returns configuration information. It is generated by C<< MyApp->load_config >>.

=item MyApp->mode_name()

This is a mode name for Amon2. Default implementation of this method is:

    sub mode_name { $ENV{PLACK_ENV} }

You can override this method if you want to determine the mode by other method.

=item C<< MyApp->new() >>

Create new context object.

=item C<< MyApp->bootstrap() >>

Create new context object and set it to global context.

=item C<< MyApp->base_dir() >>

This method returns application base directory.

=item C<< MyApp->load_plugin($module_name[, \%config]) >>

This method loads plugin for the application.

I<$module_name:> package name of the plugin. You can write it as two form like L<DBIx::Class>:

    __PACKAGE__->load_plugin("Web::HTTPSession");    # => loads Amon2::Plugin::Web::HTTPSession

If you want to load a plugin in your own name space, use '+' character before package name like following:
    __PACKAGE__->load_plugin("+MyApp::Plugin::Foo"); # => loads MyApp::Plugin::Foo

=item C<< MyApp->load_plugins($module_name[, \%config ], ...) >>

Load multiple plugins at one time.

If you want to load a plugin in your own name space, use '+' character before package name like following:

    __PACKAGE__->load_plugins("+MyApp::Plugin::Foo"); # => loads MyApp::Plugin::Foo

=item C<< MyApp->load_config() >>

You can get a configuration hashref from C<< config/$ENV{PLACK_ENV}.pl >>. You can override this method for customizing configuration loading method.

=item C<< MyApp->add_config() >>

DEPRECATED.

=back

=head1 DOCUMENTS

More complicated documents are available on http://amon.64p.org/

=head1 SUPPORTS

#amon at irc.perl.org is available.

=head1 AUTHOR

Tokuhiro Matsuno

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

