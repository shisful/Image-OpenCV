use strict;
use warnings;

use Test::More;
use Image::OpenCV;
use Image::OpenCV::Image;


my $openCV = Image::OpenCV->new();
my $img = $openCV->newImage();
isa_ok($img, 'Image::OpenCV::Image');
my $width = 400;
my $height = 280;

ok($img->load('t/test.jpg'));
is(scalar $img->width, 512);
is(scalar $img->height, 512);
is(scalar $img->depth, 8);
is(scalar $img->nChannels, 3);


unlink 't/test_out.jpg';
ok($img->saveImage('t/test_out.jpg'));
ok( -f 't/test_out.jpg');
ok($img->load('t/test_out.jpg'));

$img->load('t/test.jpg');

ok($img->convertToGray());
my $gray = $img->convertToGray();
is(scalar $gray->width, 512);
is(scalar $gray->height, 512);
is(scalar $gray->depth, 8);
is(scalar $gray->nChannels, 1);
$gray->release;

ok($img->laplace());

ok($img->canny());
my $canny = $img->canny();
is(scalar $canny->width, 512);
is(scalar $canny->height, 512);
is(scalar $canny->depth, 8);
is(scalar $canny->nChannels, 1);
$canny->release;

ok($img->resize($width,$height));
my $resize = $img->resize($width,$height);
is(scalar $resize->width, $width);
is(scalar $resize->height, $height);
is(scalar $resize->depth, 8);
is(scalar $resize->nChannels, 3);
$resize->release;


ok($img->width);
ok($img->height);
ok($img->nChannels);
ok($img->depth());
ok($img->widthStep());
ok($img->valueAt(40,30));

ok($img->copy());
my $copy = $img->copy();
is(scalar $copy->width, 512);
is(scalar $copy->height, 512);
is(scalar $copy->depth, 8);
is(scalar $copy->nChannels, 3);
$copy->release;

ok($img->trim(50,50,200,200));
my $trim = $img->trim(50,50,200,200);
is(scalar $trim->width, 200);
is(scalar $trim->height, 200);
is(scalar $trim->depth, 8);
is(scalar $trim->nChannels, 3);
$trim->release;

ok($img->release);
done_testing;
