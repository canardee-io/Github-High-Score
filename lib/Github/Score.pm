package Github::Score;
use strict;
use warnings;
use LWP;
use JSON;
use HTTP::Request;
use URI;

use Data::Dumper;

use Moose; # automatically turns on strict and warnings

  has 'user' => (is => 'rw', );
  has 'repo' => (is => 'rw', );
  has 'timeout' => (is => 'rw', );

  sub clear {
      my $self = shift;
      $self->$_(undef) for qw(ua user json uri timeout);
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

__DATA__
Kind of thing you get from the api:
$VAR1 = [
          {
            'gravatar_id' => 'dd9aceaf17982bc33972b3bb8701cd19',
            'location' => 'O\'Fallon, IL',
            'name' => 'Jesse Luehrs',
            'blog' => 'http://tozt.net/',
            'login' => 'doy',
            'email' => 'doy at tozt dot net',
            'type' => 'User',
            'company' => 'Infinity Interactive',
            'contributions' => 119
          },
          {
            'gravatar_id' => '0bffad37a60feece78c306af4456f53a',
            'name' => 'Stevan Little',
            'blog' => 'http://moose.perl.org',
            'login' => 'stevan',
            'email' => 'stevan.little@iinteractive.com',
            'type' => 'User',
            'company' => 'Infinity Interactive',
            'contributions' => 36
          },
          {
            'gravatar_id' => 'c68ae3a25b34be3310bd975c2036940d',
            'location' => 'Annville, PA',
            'name' => 'Jason May',
            'blog' => 'http://jarsonmar.org/',
            'login' => 'jasonmay',
            'email' => 'jason.a.may@gmail.com',
            'type' => 'User',
            'company' => 'Best Practical Solutions',
            'contributions' => 5
          },
          {
            'gravatar_id' => 'be68b0e46958d0dcb621f696f9b1bc1c',
            'location' => 'Revere, MA',
            'name' => 'Justin Hunter',
            'blog' => 'http://warpedreality.org',
            'login' => 'arcanez',
            'email' => 'justin.d.hunter@gmail.com',
            'type' => 'User',
            'company' => 'Cantella',
            'contributions' => 3
          }
        ];
