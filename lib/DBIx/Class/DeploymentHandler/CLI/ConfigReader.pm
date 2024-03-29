package DBIx::Class::DeploymentHandler::CLI::ConfigReader;

use strict;
use warnings;

use Moo;
use Config::Any;
use File::HomeDir;
use Types::Standard qw/ArrayRef HashRef Maybe/;
use Types::Common::String qw/NonEmptyStr/;

use namespace::clean;

=head1 NAME

DBIx::Class::DeploymentHandler::CLI::ConfigReader - Config reader class for Deployment Handler CLI.

=head1 Description

Searches the configuration file in the following locations:

=over 4

=item C<$ENV{DBIX_CONFIG_DIR}>

=item current directory

=item home directory

=item C</etc> directory

=back

The config accessor will return undefined if a configuration file is absent in all these locations.

=head1 Attributes

=head2 config

Configuration values as a hash reference. Generated by builder.

=head2 config_name

Name for the configuration file without the suffix. Defaults to C<dh-cli>.

=head2 config_files

List of configuration files.

=head2 config_paths

List of configuration paths.

=cut

has config => (
    is      => 'ro',
    isa     => Maybe[HashRef],
    lazy    => 1,
    builder => '_build_config',
);

has config_name => (
    is      => 'ro',
    isa     => NonEmptyStr,
    default => 'dh-cli',
);

has config_files => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
);

has config_paths => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    builder => '_builder_config_paths',
);

sub _build_config {
    my ($self) = @_;

    # If we have ->config_files, we'll use those and load_files
    # instead of the default load_stems.
    my %cf_opts = ( use_ext => 1 );
    my $configs =  @{$self->config_files}
        ? Config::Any->load_files({ files => $self->config_files, %cf_opts })
        : Config::Any->load_stems({ stems => $self->config_paths, %cf_opts });

    # return configuration from first existing configuration file
    for my $cf (@$configs) {
        for my $filename ( keys %$cf ) {
            return $cf->{$filename};
        }
    }

    return undef;
}

sub _builder_config_paths {
    my ($self) = @_;
    my $config_name = $self->config_name;

    return [
        $self->get_env_vars,
        ".$config_name",
        File::HomeDir->my_home . '/.' . $config_name,
        "/etc/$config_name",
    ];
}

=head1 Methods

=head2 get_env_vars

Returns stem for environment variable C<DBIX_CONFIG_DIR>.

=cut

sub get_env_vars {
    my ($self) = @_;

    return $ENV{DBIX_CONFIG_DIR} . "/" . $self->config_name if exists $ENV{DBIX_CONFIG_DIR};
    return ();
}

1;
