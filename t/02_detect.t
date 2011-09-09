use strict;
use warnings;

use Test::More;
use Image::OpenCV;
#use Image::OpenCV::Image;
use Data::Dumper;
my $cascade = '/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml';
plan tests => 10;

my $openCV = Image::OpenCV->new();
my $image = $openCV->loadImage('t/test.jpg');
my @faces = $openCV->detect($image,$cascade);
is(scalar @faces, 1); # 1 persons
my $face = shift @faces;
ok(exists $face->{x});
ok(exists $face->{y});
ok(exists $face->{width});
ok(exists $face->{height});
my $img = $openCV->newImage();
$img->load('t/test.jpg');
my @faces2 = $img->detect($cascade);
is(scalar @faces2, 1); # 1 persons
my $face2 = shift @faces2;

ok(exists $face->{x});
ok(exists $face->{y});
ok(exists $face->{width});
ok(exists $face->{height});
