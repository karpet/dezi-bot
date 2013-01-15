package Dezi::Bot;
use warnings;
use strict;
use base qw( SWISH::Prog::Class );
use SWISH::Prog::Aggregator::Spider;
use Dezi::Bot::Queue;
use Dezi::Bot::Cache;
use Parallel::Prefork;

our $VERSION = '0.001';

=head1 NAME

Dezi::Bot - web crawler

=head1 SYNOPSIS

 use Dezi::Bot;

 my $bot = Dezi::Bot->new(
    workers => 4,  # will fork this many spiders
    
    # each worker does hands every crawled URI
    # to the handle() method of an instance of this class
    handler => 'Dezi::Bot::Handler',
    
    # passed to SWISH::Prog::Aggregator::Spider->new()
    spider_config   => {
        agent      => 'dezibot ' . $Dezi::Bot::VERSION,
        email      => 'bot@dezi.org',
        max_depth  => 4,
    },
    
    # passed to Dezi::Bot::Cache->new()
    cache_config => {
        driver      => 'File',
        root_dir    => '/tmp/dezibot',
    },
    
    # passed to Dezi::Bot::Queue->new()
    queue_config => {
        type     => 'DBI',
        dsn      => "DBI:mysql:database=dezibot;host=localhost;port=3306",
        username => 'myuser',
        password => 'mysecret',
    },
 );
 
 $bot->crawl('http://dezi.org');

=head1 DESCRIPTION

The Dezi::Bot module uses SWISH::Prog::Aggregator::Spider
optimized for parallel use.

=cut

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

