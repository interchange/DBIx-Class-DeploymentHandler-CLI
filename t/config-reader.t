use strict;
use warnings;

use Test::More;
use Test::Warnings;

use DBIx::Class::DeploymentHandler::CLI::ConfigReader;

my $conf_reader = DBIx::Class::DeploymentHandler::CLI::ConfigReader->new;
my $conf_paths = $conf_reader->config_paths;

isa_ok($conf_paths, 'ARRAY');

done_testing;
