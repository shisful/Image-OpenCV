use strict;
use warnings;

use Test::More;
use Image::OpenCV;
use Image::OpenCV::Image;


my $openCV = Image::OpenCV->new();
my $img = $openCV->newImage();
my $in = 0;
is(scalar $img->load($in), undef);
$in = "t/04_error.t";
is(scalar $img->load($in), undef);
$in = "t/error.jpg";
is(scalar $img->load($in), undef);

done_testing;
