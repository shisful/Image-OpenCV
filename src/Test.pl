use strict;
use warnings;
use Image::OpenCV;
use Image::OpenCV::Image;
use SmartTrim;

my $CASCADE_FILE = '/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml';#get_app_config('opencv_cascade_file') || '/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml';

my $cv = Image::OpenCV->new();

my $out = $cv->trackingFaceOnMovie($CASCADE_FILE);
#$cv->showImage($out,"hoge");

#$cv->saveImage("/Users/hys/Develop/Perl/Image-OpenCV/hoge.jpg",$out);

#<STDIN>;