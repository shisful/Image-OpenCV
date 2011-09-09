package Image::OpenCV::Image;
use strict;
use warnings;
use Image::OpenCV;
use Carp qw(croak);
#for user


sub new {
    my $pkg = shift;
    my $img = shift;
    bless {
        img => $img
    },$pkg;
}

sub load {
    my ($self, $filename) = @_;
    if( !defined($filename) ){
        croak('arguments undefined.');
    }
    if( -f $filename ){
        my $openCV = Image::OpenCV->new();
        my $img = $openCV->xs_loadImage($filename);
        if ( exists($self->{img}) ) {
            my $old = $self->{img};
            $openCV->xs_releaseImage($old);
        }
        $self->{img} = $img;
    }else{
        return;
    }
}


sub saveImage {
    my ($self, $filename) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    if( !defined($filename) ){
        croak('arguments undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $ret = $openCV->xs_saveImage($filename,$self->{img});
}

sub width {
    my ($self) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    $openCV->getWidth($self->{img});
}
sub height {
    my ($self) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    $openCV->getHeight($self->{img});
}
sub depth {
    my ($self) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    $openCV->getDepth($self->{img});
}
sub nChannels {
    my ($self) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    $openCV->getChannel($self->{img});
}

sub convertToGray {
    my ($self) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $img = $openCV->xs_convertToGray($self->{img});
    Image::OpenCV::Image->new($img);
}

sub release {
    my ($self) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    $openCV->xs_releaseImage($self->{img});
    delete $self->{img};
    return 1;
}

sub laplace {
    my ($self, $image) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $img = $openCV->xs_laplace($self->{img});
    Image::OpenCV::Image->new($img);
}

sub canny {
    my ($self, $image) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $img = $openCV->xs_canny($self->{img});
    Image::OpenCV::Image->new($img);
}

sub resize {
    my ($self,$width,$height) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    if( !defined($width) || !defined($height)){
        croak('arguments undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $img = $openCV->xs_resize($self->{img},$width,$height);
    Image::OpenCV::Image->new($img);
}

sub widthStep {
    my ($self) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $ret = $openCV->xs_getWidthStep($self->{img});
}

sub valueAt {
    my ($self,$x,$y) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    if( !defined($x) || !defined($y) ){
        croak('arguments undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $ret = $openCV->xs_getValueAt($self->{img},$x,$y);
}

sub copy {
    my ($self) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $img = $openCV->xs_copy($self->{img});
    Image::OpenCV::Image->new($img);
}

sub trim {
    my ($self, $left, $top, $width, $height) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
     if( !defined($left) || !defined($top) || !defined($width) || !defined($height) ){
        croak('arguments undefined.');
    }
    my $openCV = Image::OpenCV->new();
    my $img = $openCV->xs_trim($self->{img}, $left, $top, $width, $height);
    Image::OpenCV::Image->new($img);
}

sub detect {
    my ($self,$cascadeFile) = @_;
    if( !defined($self->{img}) ) {
        croak('image undefined.');
    }
    if( !defined($cascadeFile) ){
        croak('arguments undefined.');
    }
    my $ret;
    if($self->cascadeCheck($cascadeFile) == 1){
       my $openCV = Image::OpenCV->new();
       $ret = $openCV->xs_detect($self->{img},$cascadeFile);
    }else{
        $ret = [];
    }
    wantarray ? @$ret : $ret;
}

sub show {
    my ($self,$name) = @_;
    my $openCV = Image::OpenCV->new();
    if ( !$name){
        $name = " ";
    }
    $openCV->xs_showImage($self->{img}, $name);
    return 1;
}


sub showWith {
    my ($self,$name,$imageA,$nameA) = @_;
    my $openCV = Image::OpenCV->new();
    $openCV->xs_showTwoImages($self->{img},$name,$imageA->{img},$nameA);

}

sub showWithWith {
    my ($self,$windowNameA,$image2,$windowNameB,$image3,$windowNameC) = @_;
    my $openCV = Image::OpenCV->new();
    $openCV->xs_showThreeImages($self->{img},$windowNameA,$image2->{img},$windowNameB,$image3->{img},$windowNameC);
}

sub checkBackground {
    my ($self,$mode) = @_;
    my $openCV = Image::OpenCV->new();
    $openCV->xs_backgroundCheck($self->{img},$mode);
}

sub addWhite {
    my ($self, $length, $mode) = @_;
    my $openCV = Image::OpenCV->new();
    my $img = $openCV->xs_addWhite( $self->{img}, $length, $mode );
    Image::OpenCV::Image->new($img);
}


sub cascadeCheck {
    my ($self,$cascade) = @_;
    my ($ext) = $cascade =~ /(\.\w{1,4})$/;
    if( $cascade && -f $cascade){
        my ($ext) = $cascade =~ /(\.\w{1,4})$/;
        if( $ext eq '.xml' || $ext eq 'xml'){
            return 1;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}


sub DESTROY{
    my $self = shift;
    if( defined($self->{img}) ) {
        $self->release();
    }
}

1;
