use 5.00503;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Authen::Captcha',
    'VERSION_FROM'	=> 'Captcha.pm', # finds $VERSION
    'PREREQ_PM'		=> {
	                    'File::Spec'	=> 0,
	                    'File::Basename'	=> 0,
	                    'Digest::MD5'	=> 0,
	                    'GD'	=> 0,
	                   },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Captcha.pm', # retrieve abstract from module
       AUTHOR     => 'Seth T. Jackson <sjackson@purifieddata.net>') : ()),
);
