use strict;
use warnings;

use Test::More;
use Test::Warnings;
use File::HomeDir;

use DBIx::Class::DeploymentHandler::CLI::ConfigReader;

my $home_path = File::HomeDir->my_home;
my $conf_paths = test_paths();

isa_ok($conf_paths, 'ARRAY');
is_deeply($conf_paths, [ '.dh-cli', "$home_path/dh-cli", '/etc/dh-cli' ]);

sub test_paths {
    my (@args) = @_;
    my $conf_reader = DBIx::Class::DeploymentHandler::CLI::ConfigReader->new( @args );
    return $conf_reader->config_paths;
}

done_testing;
