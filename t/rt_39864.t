# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# Reproduce RT #39864 https://rt.cpan.org/Ticket/Display.html?id=39864

use Test; # (tests => 28);
plan tests => 4;

use Authen::Captcha;
use Test::TempDir::Tiny;

ok(1); # If we made it this far, we are fine.

# make temp directories
my $temp_datadir 	= tempdir("data");
my $temp_outputdir 	= tempdir("img");

my $captcha = Authen::Captcha->new(
		data_folder 		=> $temp_datadir,
		output_folder 		=> $temp_outputdir,
		expire 				=> 0,
);
my $ratio = numbers_ratio($captcha, 100);
ok(abs($ratio - 0.25) < 0.1);


$captcha = Authen::Captcha->new(
		data_folder 		=> $temp_datadir,
		output_folder 		=> $temp_outputdir,
		expire 				=> 0,
		numbers_percentage	=> 0,
);
$ratio = numbers_ratio($captcha, 100);
ok($ratio == 0);


$captcha = Authen::Captcha->new(
		data_folder 		=> $temp_datadir,
		output_folder 		=> $temp_outputdir,
		expire 				=> 0,
		numbers_percentage	=> 100,
);
$ratio = numbers_ratio($captcha, 100);
ok($ratio == 1);


sub numbers_ratio {
	my($captcha, $tries) = @_;
	my $nums = 0;
	my $chars = 0;
	for (1 .. $tries) {
		my($md5sum, $code) = $captcha->generate_code('4');
		$nums += ($code =~ tr/0-9/0-9/);
		$chars += length($code);
	}
	return $nums / $chars;
}
