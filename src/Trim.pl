use strict;
use warnings;
use Image::OpenCV;
use Image::OpenCV::Image;
use SmartTrim;

my $dir = shift;
my $savedir = shift;

opendir DH, $dir or die "$dir:$!";
while (my $file = readdir DH ) {
    next if $file =~ /^\.{1,2}$/;	# '.'や'..'も取れるので、スキップする
    my $filename = $dir."/".$file;
    warn $file." : ";


    my $trimer = SmartTrim->new();
    my $cv = Image::OpenCV->new();
    my $input_image = $cv->newImage();
    $input_image->load($filename);
    my $out = $trimer->smart_trimmed_image($input_image, 100, 70);
    $out->saveImage($savedir."/".$file);
}
closedir DH;
