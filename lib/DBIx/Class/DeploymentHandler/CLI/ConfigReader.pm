package DBIx::Class::DeploymentHandler::CLI::ConfigReader;

use strict;
use warnings;

use Moo;
use Config::Any;
use File::HomeDir;
use Types::Standard qw/ArrayRef HashRef/;
use Types::Common::String qw/NonEmptyStr/;

use namespace::clean;

has config => (
    is      => 'ro',
    isa     => HashRef,
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
    return @{$self->config_files}
        ? Config::Any->load_files({ files => $self->config_files, %cf_opts })
        : Config::Any->load_stems({ stems => $self->config_paths, %cf_opts });
}

sub _builder_config_paths {
    my ($self) = @_;
    my $config_name = $self->config_name;

    return [
        $self->get_env_vars,
        ".$config_name",
        File::HomeDir->my_home . '/' . $config_name,
        "/etc/$config_name",
    ];
}

sub get_env_vars {
    my ($self) = @_;

    return $ENV{DBIX_CONFIG_DIR} . "/" . $self->config_name if exists $ENV{DBIX_CONFIG_DIR};
    return ();
}

1;
