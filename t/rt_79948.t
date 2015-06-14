# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# Reproduce RT #79948 https://rt.cpan.org/Ticket/Display.html?id=79948

use Test; # (tests => 28);
plan tests => 6;

my $SEED = 23;		# make tests predictable
my $EXPIRE = 600;

use Authen::Captcha;
use Test::TempDir::Tiny;

ok(1); # If we made it this far, we are fine.

# make temp directories
my $temp_datadir 	= tempdir("data");
my $temp_outputdir 	= tempdir("img");
my $db_file = "$temp_datadir/codes.txt";

# cleanup database, if any
unlink(<$temp_datadir/*>);
unlink(<$temp_outputdir/*>);

my $captcha = Authen::Captcha->new(
		data_folder 	=> $temp_datadir,
		output_folder 	=> $temp_outputdir,
		expire 			=> $EXPIRE,
);

srand($SEED);		
my($md5sum, $code) = $captcha->generate_code('4');
ok(-f "$temp_outputdir/$md5sum.png");


# create a database with an expired entry
ok(open(my $fh, ">", $db_file));
print $fh time - 2 * $EXPIRE, "::", $md5sum, "::", $code,"\n";
close($fh);

# reset seed and create a new entry -> image file was deleted
srand($SEED);		
($md5sum, $code) = $captcha->generate_code('4');
ok(-f "$temp_outputdir/$md5sum.png");

# create a database with a not-expired entry
ok(open(my $fh, ">", $db_file));
print $fh time, "::", $md5sum, "::", $code,"\n";
close($fh);

# reset seed and create a new entry -> duplicate entry not written twice
srand($SEED);		
($md5sum, $code) = $captcha->generate_code('4');
ok(-f "$temp_outputdir/$md5sum.png");
