use strict;
use warnings;

use Test::More;
use Image::OpenCV;


my $openCV = Image::OpenCV->new();
isa_ok($openCV, 'Image::OpenCV');
my $width = 400;
my $height = 280;
ok($openCV->loadImage('t/test.jpg'));
my $img = $openCV->loadImage('t/test.jpg');
is(scalar $openCV->getWidth($img), 512);
is(scalar $openCV->getHeight($img), 512);
is(scalar $openCV->getDepth($img), 8);
is(scalar $openCV->getChannel($img), 3);

my $img2;
ok($img2 = $openCV->createImage($width,$height,8,3));
is(scalar $openCV->getWidth($img2), $width);
is(scalar $openCV->getHeight($img2), $height);
is(scalar $openCV->getDepth($img2), 8);
is(scalar $openCV->getChannel($img2), 3);

ok($openCV->releaseImage($img2));

unlink 't/test_out.jpg';
ok($openCV->saveImage('t/test_out.jpg',$img));
ok( -f 't/test_out.jpg');
ok($openCV->loadImage('t/test_out.jpg'));
$img = $openCV->loadImage('t/test.jpg');
is(scalar $openCV->getWidth($img), 512);
is(scalar $openCV->getHeight($img), 512);
is(scalar $openCV->getDepth($img), 8);
is(scalar $openCV->getChannel($img), 3);

ok($openCV->convertToGray($img));
my $gray = $openCV->convertToGray($img);
is(scalar $openCV->getWidth($gray), 512);
is(scalar $openCV->getHeight($gray), 512);
is(scalar $openCV->getDepth($gray), 8);
is(scalar $openCV->getChannel($gray), 1);
$openCV->releaseImage($gray);

ok($openCV->laplace($img));

ok($openCV->canny($img));
my $canny = $openCV->canny($img);
is(scalar $openCV->getWidth($canny), 512);
is(scalar $openCV->getHeight($canny), 512);
is(scalar $openCV->getDepth($canny), 8);
is(scalar $openCV->getChannel($canny), 1);
$openCV->releaseImage($canny);

ok($openCV->resize($img,$width,$height));
my $resize = $openCV->resize($img,$width,$height);
is(scalar $openCV->getWidth($resize), $width);
is(scalar $openCV->getHeight($resize), $height);
is(scalar $openCV->getDepth($resize), 8);
is(scalar $openCV->getChannel($resize), 3);
$openCV->releaseImage($resize);

ok($openCV->getWidth($img));
ok($openCV->getHeight($img));
ok($openCV->getChannel($img));
ok($openCV->getDepth($img));
ok($openCV->getWidthStep($img));
ok($openCV->getValueAt($img,40,30));

ok($openCV->copy($img));
my $copy = $openCV->copy($img);
is(scalar $openCV->getWidth($copy), 512);
is(scalar $openCV->getHeight($copy), 512);
is(scalar $openCV->getDepth($copy), 8);
is(scalar $openCV->getChannel($copy), 3);
$openCV->releaseImage($copy);

ok($openCV->trim($img,50,50,200,200));
my $trim = $openCV->trim($img,50,50,200,200);
is(scalar $openCV->getWidth($trim), 200);
is(scalar $openCV->getHeight($trim), 200);
is(scalar $openCV->getDepth($trim), 8);
is(scalar $openCV->getChannel($trim), 3);
$openCV->releaseImage($trim);

ok($openCV->releaseImage($img));
done_testing;
