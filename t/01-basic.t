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
