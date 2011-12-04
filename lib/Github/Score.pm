package Github::Score;
 use strict;
 use warnings;
 use LWP;
 use JSON;
 use HTTP::Request;
 use URI;
 
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
 sub user    { $_[0]->{user} }
 sub repo    { $_[0]->{repo} }
 sub timeout { $_[0]->{timeout} }
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
 
 use Test::More tests => 15;
 
 BEGIN { use_ok 'Github::Score'; }
 
 {
     isa_ok( my $gs = Github::Score->new( user => 'stevan', repo => 'ox' ), 'Github::Score' );
     is( $gs->user, 'stevan' );
     is( $gs->repo, 'ox' );
 }
 
 {
     isa_ok( my $gs = Github::Score->new( { user => 'stevan', repo => 'ox' } ), 'Github::Score' );
     is( $gs->user, 'stevan' );
     is( $gs->repo, 'ox' );
 }
 
 {
     isa_ok( my $gs = Github::Score->new( url => 'stevan/ox' ), 'Github::Score' );
     is( $gs->user, 'stevan' );
     is( $gs->repo, 'ox' );
 }
 
 {
     isa_ok( my $gs = Github::Score->new('stevan/ox'), 'Github::Score' );
     is( $gs->user, 'stevan' );
     is( $gs->repo, 'ox' );
     isa_ok( my $scores = $gs->scores, 'HASH' );
     ok( scalar %$scores );
 }

