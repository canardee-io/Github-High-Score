 use Test::More tests => 11;
use Data::Dumper;
 
 BEGIN { use_ok 'Github::Score'; }
 
 
 {
     isa_ok( my $gs = Github::Score->new( { user => 'stevan', repo => 'ox' } ), 'Github::Score' );
     is( $gs->user, 'stevan','User is stevan - separate args in constructor' );
     is( $gs->repo, 'ox','repo is ox - separate args in constructor' );
 }
 
 
 {
     isa_ok( my $gs = Github::Score->new('stevan/ox'), 'Github::Score' );
     is( $gs->user, 'stevan','User is stevan - name/repo uri' );
     is( $gs->repo, 'ox','repo is ox name/repo uri' );
     isa_ok( my $scores = $gs->scores, 'HASH' );
     cmp_ok ((my $count = grep { /(stevan|doy|arcanez|jasonmay)/} keys %$scores),
     	'>',0, "Found at least one of stevan|doy|arcanez|jasonmay");
}

{
	my $gs = Github::Score->new('stevan/ox', timeout => 0.0001);
	is($gs->timeout(), 0.0001,'Silly low non-zero timeout value');
	cmp_ok my $count = keys %{$gs->scores}, '==',0,'No scores in timeout case';
}
