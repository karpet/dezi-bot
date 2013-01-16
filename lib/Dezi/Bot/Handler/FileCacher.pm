package Dezi::Bot::Handler::FileCacher;
use strict;
use warnings;
use base 'Dezi::Bot::Handler';
use Carp;
use Digest::MD5 qw( md5_hex );
use DBIx::Connector;
use DBIx::InsertHash;
use Time::HiRes;

our $VERSION = '0.001';

=head1 NAME

Dezi::Bot::Handler::FileCacher - web crawler handler that caches files

=head1 SYNOPSIS

 use Dezi::Bot::Handler::FileCacher;
 my $handler = Dezi::Bot::Handler::FileCacher->new(
    dsn      => "DBI:mysql:database=$database;host=$hostname;port=$port",
    username => 'myuser',
    password => 'mysecret',
    root_dir => '/path/to/site/mirror',
 );
 $handler->handle( $swish_prog_doc );

=head1 DESCRIPTION

The Dezi::Bot::Handler::FileCacher writes
each doc to the filesystem, managing
its progress and status via DBI.

=head1 METHODS

=head2 new( I<config> )

Returns a new Dezi::Bot::Handler::FileCacher object.
I<config> must have:

=over

=item dsn

Passed to DBI->connect.

=item username

Passed to DBI->connect.

=item password

Passed to DBI->connect.

=item root_dir

Base path for writing cached files.

=back

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

}

=head2 handler( I<doc> )

Metadata from I<doc> is stored via DBI
and I<doc> is written to disk.

=cut

sub handler {
    my $self        = shift;
    my $doc         = shift or croak "Doc required";
    my $md5         = md5_hex( $doc->uri );
    my $md5_content = md5_hex( $doc->content );
    my $file_path   = $self->_get_path_for($md5);
}

sub _get_path_for {
    my ( $self, $md5 ) = @_;
    my ( $first, $second ) = ( $md5 =~ m/^(.)(.)/ );
    my $path = $self->{root_dir}->subdir( $first, $second );
    $path = $path->file($md5);
    return $path;
}

=head2 schema

Callable as a function or class method. Returns string suitable
for initializing a B<dezi_filecache> SQL table.

Example:

 perl -e 'use Dezi::Bot::Handler::FileCacher; print Dezi::Bot::Handler::FileCacher::schema' |\
  sqlite3 dezi.index/bot.db

=cut

sub schema {
    return <<EOF
create table dezi_filecache (
    id          integer primary key autoincrement,
    upd_time    integer,
    crawl_time  integer,
    uri         text,
    uri_md5     char(32),
    content_md5 char(32),
    priority    integer,
    queue_name  varchar(255),
    client_name varchar(255),
    constraint uri_md5_unique unique (uri_md5)
);
EOF
}

1;

__END__

=head1 METHODS

=head1 AUTHOR

Peter Karman, C<< <karman at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dezi-bot at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dezi-Bot>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dezi::Bot


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dezi-Bot>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dezi-Bot>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dezi-Bot>

=item * Search CPAN

L<http://search.cpan.org/dist/Dezi-Bot/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2013 Peter Karman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
