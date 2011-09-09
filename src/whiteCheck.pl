use strict;
use warnings;
use Image::OpenCV;
use Image::OpenCV::Image;


my $dir = '/Users/hys/Develop/Intern/pic/testImage';	# 対象ディレクトリ名(相対パスでもOKです)


opendir DH, $dir or die "$dir:$!";
while (my $file = readdir DH ) {
    next if $file =~ /^\.{1,2}$/;	# '.'や'..'も取れるので、スキップする
    my $filename = $dir."/".$file;
    warn $file." : ";
    my $b;
    open(my $fh, "<", $filename) or croak();
    read $fh, $b, 2;#先頭より2バイト分読み込む(jpeg)
    close($fh);
    if($b eq "\xff\xd8"){
        my $cv= Image::OpenCV->new();
        my $image = $cv->newImage();
        $image->load($filename);
        my $out1 = $image->checkBackground(0);
        my $out2 = $image->checkBackground(1)."\n";
        if($out1 == 1 || $out2 == 1){
            my $new = $image->whiteAdd($image->width + 300, 1);
            $image->showWith("hoge",$new,"hogehoge");
            my $str = <STDIN>;

        }
        $image->release;
    }
}
closedir DH;
