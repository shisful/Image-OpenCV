use strict;
use warnings;
use Image::OpenCV;
use Image::OpenCV::Image;
use SmartTrim;

my $file = shift;
my $gray_file = shift;
my $canny_file = shift;

my $cv = Image::OpenCV->new();
my $input_image = $cv->newImage();
$input_image->load($file);

my $gray = $input_image->convertToGray();
$gray->saveImage($gray_file);

my $canny = $gray->canny();
$canny->saveImage($canny_file);
$input_image->showWithWith("Original",$gray,"Gray Scale",$canny,"Edge Image");
my $out = <STDIN>;