use Test::More tests => 11;
use Data::Dumper;
 
BEGIN { use_ok 'Github::Score'; }
 
my $gs1 = Github::Score->new(); ##Bare constructor. Not much use without:
$gs1->user('Getty'); ## Still need a:
cmp_ok $gs1->user(), 'eq', 'Getty', 'User (Getty) explicitly set';
$gs1->repo('p5-www-duckduckgo');
cmp_ok $gs1->repo(), 'eq', 'p5-www-duckduckgo', 'Repo (p5-www-duckduckgo) explicitly set';

my $gs2 = Github::Score->new(user=>'Getty', repo=>'p5-www-duckduckgo'); 
cmp_ok $gs2->user(), 'eq', 'Getty', 'User (Getty) set by named constructor arg';
cmp_ok $gs1->repo(), 'eq', 'p5-www-duckduckgo', 'Repo (p5-www-duckduckgo) set by named constructor arg';

my $gs3 = Github::Score->new('Getty/p5-www-duckduckgo'); 
cmp_ok $gs2->user(), 'eq', 'Getty', 'User (Getty) set with url-style constructor arg';
cmp_ok $gs1->repo(), 'eq', 'p5-www-duckduckgo', 'Repo (p5-www-duckduckgo) set with url-style constructor arg';

cmp_ok $gs3->timeout(), '==', 10, 'Default timer is 10';
cmp_ok $gs3->timeout(5), '==', 5, 'Timer reset to 5';

exit;
$contributors_scores = $gs2->scores();

 
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
