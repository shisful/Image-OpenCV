package EvaluateAnyImages;

use strict;
use warnings;
use Image::OpenCV;
use Image::OpenCV::Image;


sub show_three_images{
    my ($class,$image1,$image2,$image3,$windowNameA,$windowNameB,$windowNameC) = @_;
    my $input = -1;

    $image1->showWithWith($windowNameA,$image2,$windowNameB,$image3,$windowNameC);
    while ($input == -1){
        my $str = <STDIN>;
        chomp $str;
        if($str eq 'p'){
            $input = 1;
        }elsif($str eq 'o'){
            $input = 0;
        }
    }
    return $input;
}

sub show_two_images{
    my ($class,$image1,$image2,$windowNameA,$windowNameB) = @_;
    my $input = -1;

    $image1->showWith($windowNameA,$image2,$windowNameB);
    while ($input == -1){
        my $str = <STDIN>;
        chomp $str;
        if($str eq 'p'){
            $input = 1;
        }elsif($str eq 'o'){
            $input = 0;
        }
    }
    return $input;
}

sub show_two_images_by_file{
    my ($class,$file1,$file2,$windowNameA,$windowNameB) = @_;
    my $cv = Image::OpenCV->new();
    my $image1 = $cv->newImage($file1);
    my $image2 = $cv->newImage($file2);
    my $input = -1;

    $image1->showWith($windowNameA,$image2,$windowNameB);
    while ($input == -1){
        my $str = <STDIN>;
        chomp $str;
        if($str eq 'p'){
            $input = 1;
        }elsif($str eq 'o'){
            $input = 0;
        }
    }

    $cv->destroyAllWindows();
    return $input;
}

1;