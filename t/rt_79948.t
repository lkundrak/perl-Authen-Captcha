# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# Reproduce RT #79948 https://rt.cpan.org/Ticket/Display.html?id=79948

use File::Path 'make_path', 'remove_tree';

my $SEED = 23;		# make tests predictable
my $EXPIRE = 600;
my $temp_dir = "t/captcha_temp";
my $temp_datadir = "$temp_dir/data";
my $temp_outputdir = "$temp_dir/img";
my $db_file = "$temp_datadir/codes.txt";

use Test; # (tests => 28);

plan tests => 9;

use Authen::Captcha;
ok(1); # If we made it this far, we are fine.

# make temp directories
make_path($temp_datadir, $temp_outputdir);
ok(-d $temp_datadir);
ok(-d $temp_outputdir);

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


# delete temp directories
ok(remove_tree($temp_dir) > 0); # remove temp dir
