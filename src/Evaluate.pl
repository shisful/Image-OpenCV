use strict;
use warnings;
use Image::OpenCV;
use Image::OpenCV::Image;
use SmartTrim;
use EvaluateAnyImages;


my $dir = shift;

my $windowNameA = "before";
my $windowNameB = "after";
my $cv= Image::OpenCV->new();
my $trimer = SmartTrim->new();
my $before = 0;
my $after = 0;
my $image = $cv->newImage();
my $image1;
my $image2;

opendir DH, $dir or die "$dir:$!";
while (my $file = readdir DH ) {
    next if $file =~ /^\.{1,2}$/;# '.'や'..'も取れるので、スキップする

    my $filename = $dir."/".$file;
    my $output = $dir."/out/".$file;
    if( -f $output){
    }else{
        warn $file." : ";
        $image->load($filename);

        $image1 = $trimer->smart_trimmed_image($image,400,280);
        $image2 = $trimer->smart_trimmed_image_new($image,400,280);

        my $ev = EvaluateAnyImages->show_three_images($image,$image1,$image2,"original",$windowNameA,$windowNameB);
        $image1->saveImage($output);

        $image->release;
        $image1->release;
        $image2->release;

        if($ev == 0){
            $before++;
        }else{
            $after++;
        }
        $cv->destroyAllWindows();
        print "before : $before\n";
        print "after : $after\n";
    }
}
closedir DH;
