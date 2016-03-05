package DBIx::Class::DeploymentHandler::CLI;

use 5.006;
use strict;
use warnings;

use FindBin qw($Script);
use Moo;
use Types::Standard qw/ArrayRef HashRef InstanceOf Str/;
use DBIx::Class::DeploymentHandler;

=head1 NAME

DBIx::Class::DeploymentHandler::CLI - Command line interface for deployment handler

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use DBIx::Class::DeploymentHandler::CLI;

    my $foo = DBIx::Class::DeploymentHandler::CLI->new();
    ...

=head1 ATTRIBUTES

=head2 schema

L<DBIx::Class::Schema> object. This parameter is B<required>.

=cut

has schema => (
    is => 'ro',
    isa => InstanceOf['DBIx::Class::Schema'],
    required => 1,
);

=head2 databases

Array reference with database names or single database
name as a string. This parameter is B<required>.

It is passed directly to L<DBIx::Class::DeploymentHandler>.

=cut

has databases => (
    isa     => Str | ArrayRef,
    is      => 'ro',
    default => sub { [qw( MySQL SQLite PostgreSQL )] },
    required => 1,
);

=head2 sql_translator_args

Hash reference with parameters for L<SQL::Translator>.

Defaults to:

    { add_drop_table => 0 }

It is passed directly to L<DBIx::Class::DeploymentHandler>.

=cut

has sql_translator_args => (
    isa => HashRef,
    is => 'ro',
    default => sub { { add_drop_table => 0 } },
);

=head2 args

Array reference with commandline parameters.

=cut

has args => (
    isa => ArrayRef,
    is => 'ro',
    default => sub {[]},
);

=head2 run

Determines method to be run.

=cut

sub run {
    my $self = shift;
    my $cmd;

    # check if we have commandline arguments
    if (@{$self->args}) {
        $cmd = $self->args->[0];
    }
    elsif ($Script =~ /^dh-(.*?)$/) {
        $cmd = $1;
    }

    if (defined $cmd) {
        $cmd =~ s/-/_/g;

        if ($self->can($cmd)) {
            return $self->$cmd;
        }

        die "No method for command $cmd";
    }

    die "Cannot determine command from $Script.";
}

=head2 version

Prints database and schema version.

=cut

sub version {
    my $self = shift;
    my $database_version = $self->database_version;
    my $schema_version = $self->schema_version;

    return qq{Database version: $database_version
Schema version: $schema_version};
}

=head2 database_version

Retrieves schema version from database.

=cut

sub database_version {
    my $self = shift;
    my $dh = $self->_dh_object;

    return $dh->database_version;
}

=head2 schema_version

Retrieves schema version from schema.

=cut

sub schema_version {
    my $self = shift;
    my $dh = $self->_dh_object;

    return $dh->schema_version;
}

=head2 custom_upgrade_directory

Returns custom upgrade directory if possible.

=cut

sub custom_upgrade_directory {
    my $self = shift;
    my $dh = $self->_dh_object;

    my $db_version = $self->database_version;
    my $schema_version = $self->schema_version;

    unless ($schema_version == $db_version + 1) {
        die "Schema version $schema_version needs to be one version ahead of database version $db_version.";
    }

    return "sql/_common/upgrade/${db_version}-${schema_version}";
}

=head2 prepare_version_storage

=cut

sub prepare_version_storage {
    my $self = shift;

    my $dh = $self->_dh_object;

    $dh->prepare_version_storage_install;
    $dh->prepare_deploy;
}

=head2 install_version_storage

=cut

sub install_version_storage {
    my $self = shift;

    my $dh = $self->_dh_object;

    $dh->install_version_storage( { version => 1 } );
    $dh->add_database_version( { version => 1 } );
}

sub _dh_object {
    my $self = shift;
    my $dh;

    $dh = DBIx::Class::DeploymentHandler->new(
        {
            schema              => $self->schema,
            databases           => $self->databases,
            sql_translator_args => $self->sql_translator_args,
        }
    );

    return $dh;
}

=head1 AUTHOR

Stefan Hornburg (Racke), C<< <racke at linuxia.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dbix-class-deploymenthandler-cli at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-Class-DeploymentHandler-CLI>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBIx::Class::DeploymentHandler::CLI


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-Class-DeploymentHandler-CLI>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-Class-DeploymentHandler-CLI>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-Class-DeploymentHandler-CLI>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-Class-DeploymentHandler-CLI/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Stefan Hornburg (Racke).

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of DBIx::Class::DeploymentHandler::CLI
