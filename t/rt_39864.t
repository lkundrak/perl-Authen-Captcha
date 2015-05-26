# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# Reproduce RT #39864 https://rt.cpan.org/Ticket/Display.html?id=39864

use File::Path 'make_path', 'remove_tree';

my $temp_dir = "t/captcha_temp";
my $temp_datadir = "$temp_dir/data";
my $temp_outputdir = "$temp_dir/img";

use Test; # (tests => 28);

plan tests => 9;

use Authen::Captcha;
ok(1); # If we made it this far, we are fine.

# make temp directories
make_path($temp_datadir, $temp_outputdir);
ok(-d $temp_datadir);
ok(-d $temp_outputdir);

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


# delete temp directories
ok(remove_tree($temp_dir) > 0); # remove temp dir



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
