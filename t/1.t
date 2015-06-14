# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

use Test; # (tests => 28);

plan tests => 33;

# we set this only for testing, it is not actually used
my $temp_imagesdir = 'Captcha/images';

use Authen::Captcha;
use Test::TempDir::Tiny;

ok(1); # If we made it this far, we are fine.

# make temp directories
my $temp_datadir 	= tempdir("data");
my $temp_outputdir 	= tempdir("img");

my $captcha = Authen::Captcha->new();
ok( defined $captcha, 1, 'new() did not return anything' );
ok( $captcha->isa('Authen::Captcha') );

my $captcha2 = Authen::Captcha->new(
	debug    	=> 1,
	data_folder	=> $temp_datadir,
	output_folder	=> $temp_outputdir,
	expire  	=> 301,
	width   	=> 26,
	height  	=> 36,
	keep_failures	=> 1,
	);
ok( defined $captcha2, 1, 'new() did not return anything' );
ok( $captcha2->isa('Authen::Captcha') );

$captcha->debug(1);
ok( $captcha->debug(), '1', "couldn't set debug to 1" );
ok( $captcha2->debug(), '1', "couldn't set debug to 1" );

$captcha->data_folder($temp_datadir);
ok( $captcha->data_folder(), $temp_datadir, "couldn't set data folder to $temp_datadir" );
ok( $captcha2->data_folder(), $temp_datadir, "couldn't set data folder to $temp_datadir" );

$captcha->output_folder($temp_outputdir);
ok( $captcha->output_folder(), $temp_outputdir, "couldn't set data folder to $temp_outputdir" );
ok( $captcha2->output_folder(), $temp_outputdir, "couldn't set data folder to $temp_outputdir" );

$captcha->expire(301);
ok( $captcha->expire(), '301', "couldn't set expire to 301" );
ok( $captcha2->expire(), '301', "couldn't set expire to 301" );

$captcha->width(26);
ok( $captcha->width(), '26', "couldn't set width to 26" );
ok( $captcha2->width(), '26', "couldn't set width to 26" );

$captcha->height(36);
ok( $captcha->height(), '36', "couldn't set height to 36" );
ok( $captcha2->height(), '36', "couldn't set height to 36" );

$captcha->keep_failures(1);
ok( $captcha->keep_failures(), '1', "couldn't set keep_failures to 1" );
ok( $captcha2->keep_failures(), '1', "couldn't set keep_failures to 1" );

my $default_images_folder = $captcha->images_folder();
$captcha->images_folder($temp_imagesdir);
ok( $captcha->images_folder(), $temp_imagesdir, "Couldn't override the images_folder to $temp_imagesdir");
$captcha->images_folder($default_images_folder);
ok( $captcha->images_folder(), $default_images_folder, "Couldn't set the images_folder back to $default_images_folder");

ok( $captcha->numbers_percentage() == 25 );
$captcha->numbers_percentage(50);
ok( $captcha->numbers_percentage() == 50 );
$captcha->numbers_percentage(0);
ok( $captcha->numbers_percentage() == 0 );
$captcha->numbers_percentage(100);
ok( $captcha->numbers_percentage() == 100 );
$captcha->numbers_percentage(25);

my ($md5sum,$code) = $captcha->generate_code(5);
ok( sub { return 1 if (length($code) == 5) }, 1, "didn't set the number of captcha characters correctly" );

# we have keep_failures on, so this should not get rid of the database entry
my $bad_results = $captcha2->check_code($code . 'x',$md5sum);
ok( sub { return 1 if ($bad_results == -3) }, 1, "Failed on check_code: it did not fail correctly" );
$captcha2->keep_failures(0);

my $results = $captcha2->check_code($code,$md5sum);
# check for different error states
ok( sub { return 1 if ($results != -3) }, 1, "Failed on check_code: invalid code (code does not match crypt)" );
ok( sub { return 1 if ($results != -2) }, 1, "Failed on check_code: invalid code (not in database)" );
ok( sub { return 1 if ($results != -1) }, 1, "Failed on check_code: code expired" );
ok( sub { return 1 if ($results !=  0) }, 1, "Failed on check_code: code not checked (file error)" );
ok( $results,  1, "Failed on check_code, didn't return 1, but didn't return the other error codes either." );

# we disabled keep_failures, so the check should fail
my $bad_results2 = $captcha2->check_code($code,$md5sum);
ok( sub { return 1 if ($bad_results2 == -2) }, 1, "Failed on check_code: disabling keep_failures did not work right, it failed incorrectly" );
