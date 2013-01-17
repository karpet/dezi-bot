package Dezi::Bot;
use warnings;
use strict;
use base qw( SWISH::Prog::Class );
use Carp;
use Data::Dump qw( dump );
use Module::Load;
use SWISH::Prog::Test::Indexer;
use Parallel::ForkManager;

our $VERSION = '0.001';

__PACKAGE__->mk_accessors(
    qw(
        name
        workers
        handler_class
        handler_config
        queue_class
        queue_config
        cache_class
        cache_config
        spider_class
        spider_config
        )
);

=head1 NAME

Dezi::Bot - parallel web crawler

=head1 SYNOPSIS

 use Dezi::Bot;

 my $bot = Dezi::Bot->new(
 
    # will fork this many spiders
    workers => 4,  
    
    # each worker hands every crawled URI
    # to the $handler->handle() method
    handler_class => 'Dezi::Bot::Handler',
    
    # default
    spider_class => 'Dezi::Bot::Spider',
    
    # passed to spider_class->new()
    spider_config   => {
        agent      => 'dezibot ' . $Dezi::Bot::VERSION,
        email      => 'bot@dezi.org',
        max_depth  => 4,
    },
    
    # default
    cache_class => 'Dezi::Bot::Cache',
    
    # passed to cache_class->new()
    cache_config => {
        driver      => 'File',
        root_dir    => '/tmp/dezibot',
    },
    
    # default
    queue_class => 'Dezi::Bot::Queue',
    
    # passed to queue_class->new()
    queue_config => {
        type     => 'DBI',
        dsn      => "DBI:mysql:database=dezibot;host=localhost;port=3306",
        username => 'myuser',
        password => 'mysecret',
    },
 );
 
 $bot->crawl('http://dezi.org');

=head1 DESCRIPTION

The Dezi::Bot module is a web crawler optimized for parallel
use across multiple hosts.

=cut

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self->{name}          ||= 'dezibot';
    $self->{workers}       ||= 1;
    $self->{spider_class}  ||= 'Dezi::Bot::Spider';
    $self->{cache_class}   ||= 'Dezi::Bot::Cache';
    $self->{queue_class}   ||= 'Dezi::Bot::Queue';
    $self->{handler_class} ||= 'Dezi::Bot::Handler';

    load( $self->{spider_class} );
    load( $self->{cache_class} );
    load( $self->{queue_class} );
    load( $self->{handler_class} );

    # TODO default configs?
    $self->{handler_config} ||= {};
    $self->{cache_config}   ||= {};
    $self->{queue_config}   ||= {};
    $self->{spider_config}  ||= {};

    return $self;
}

sub crawl {
    my $self   = shift;
    my @urls   = @_;
    my $spider = $self->_init_spider();
    return $spider->crawl(@urls);
}

sub _init_spider {
    my $self = shift;
    my %args = @_;

    my $handler = $self->handler_class->new( %{ $self->handler_config } );

    my $spider = $self->spider_class->new(
        %{ $self->spider_config },
        queue     => $self->queue_class->new( %{ $self->queue_config } ),
        uri_cache => $self->cache_class->new( %{ $self->cache_config } ),
        md5_cache => $self->cache_class->new( %{ $self->cache_config } ),
        %args,
        filter => sub {
            my $doc = shift;
            $handler->handle( $self, $doc );
            return $doc;
        },
    );

    return $spider;
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

