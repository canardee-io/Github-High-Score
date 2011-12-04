package Github::Score;
use strict;
use warnings;
use LWP;
use JSON;
use HTTP::Request;
use URI;

use Moose; # automatically turns on strict and warnings

  has 'user' => (is => 'rw', );
  has 'repo' => (is => 'rw', );
  has 'timeout' => (is => 'rw', );

  sub clear {
      my $self = shift;
      $self->$_(undef) for qw(ua user json uri);
  }

##  package Point3D;
##  use Moose;
##
##  extends 'Point';
##
##  has 'z' => (is => 'rw', isa => 'Int');
##
##  after 'clear' => sub {
##      my $self = shift;
##      $self->z(0);
##  }; 

 our $VERSION = '0.001';
 $VERSION = eval $VERSION;
 
 sub new {
     my $self = shift;
     my @args = @_;
 
     unshift @args, 'url' if @args % 2 && !ref( $args[0] );
 
     my %args = ref( $args[0] ) ? %{ $args[0] } : @args;
     if ( exists $args{url} ) {
         ( $args{user}, $args{repo} ) = ( split /\//, delete $args{url} );
     }
 
     my $timeout = $args{timeout} || 10;
 
     bless { user => $args{user}, repo => $args{repo}, timeout => $timeout }, $self;
 }
 
 sub ua { LWP::UserAgent->new( timeout => $_[0]->timeout, agent => join ' ', ( __PACKAGE__, $VERSION ) ); }
#sub user    { $_[0]->{user} }
# sub repo    { $_[0]->{repo} }
# sub timeout { $_[0]->{timeout} }
 sub uri { URI->new( sprintf( 'http://github.com/api/v2/json/repos/show/%s/%s/contributors', $_[0]->user, $_[0]->repo ) ); }
 sub json { JSON->new->allow_nonref }
 
 sub scores {
     my $self = shift;
 
     my $response = $self->ua->request( HTTP::Request->new( GET => $self->uri->canonical ) );
     return {} unless $response->is_success;
 
     my %scores;
     my $contributors = $self->json->decode( $response->content )->{contributors};
 
     map { $scores{ $_->{login} } = $_->{contributions} } @$contributors;
     return \%scores;
 }
 
 1;
 
# ABSTRACT: a really awesome library
##
=head1 SYNOPSIS
use Github::Score;

...

=method method_x

This method does something experimental.

=method method_y

This method returns a reason.

=head1 SEE ALSO

=for :list
* L<Your::Module>
* L<Your::Package>
