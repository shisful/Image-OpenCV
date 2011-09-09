package Image::OpenCV;
use strict;
use warnings;
use Image::OpenCV::Image;
use vars qw($VERSION @ISA @EXPORT);
use Carp qw(croak);
#for standard user

BEGIN {
    $VERSION = '0.1';
    if ($] > 5.006) {
        require XSLoader;
        XSLoader::load(__PACKAGE__, $VERSION);
    } else {
        require DynaLoader;
        @ISA = qw(DynaLoader);
        __PACKAGE__->bootstrap;
    }
    require Exporter;
    push @ISA, 'Exporter';
}



sub bless_to_image {
    my ($self,$img) = @_;
    my $ret = Image::OpenCV::Image->new($img);
}

sub newImage {
    my($self,$file) = @_;
    my $img;
    if($file){
        $img = $self->xs_loadImage($file);
    }else{
        $img = $self->xs_createImage(1,1,8,1);
    }
    my $ret = Image::OpenCV::Image->new($img);
}


sub createImage {
    my ($self, $width, $height, $IPL_DEPTH, $Channel) = @_;
    if( !defined($width) || !defined($height) || !defined($IPL_DEPTH) || !defined($Channel) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_createImage($width,$height,$IPL_DEPTH,$Channel);

    return $ret;
}

sub loadImage {
    my ($self, $filename) = @_;
    if( !defined($filename) ){
        croak('arguments undefined.');
    }
    if( ! -f $filename ){
        croak('no file.');
    }
    my $img = $self->xs_loadImage($filename);
}


sub saveImage {
    my ($self, $filename,$image) = @_;
    if( !defined($image) || !defined($filename)){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_saveImage($filename,$image);
}

sub convertToGray {
    my ($self, $image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_convertToGray($image);
}

sub releaseImage {
    my ($self, $image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    $self->xs_releaseImage($image);
    return 1;
}

sub laplace {
    my ($self, $image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_laplace($image);
    return $ret;
}

sub canny {
    my ($self, $image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_canny($image);
    return $ret;
}

sub resize {
    my ($self,$image,$width,$height) = @_;
    if( !defined($image) || !defined($width) || !defined($height) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_resize($image,$width,$height);
}

sub getWidth {
    my ($self,$image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_getWidth($image);
    return $ret;
}

sub getHeight {
    my ($self,$image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_getHeight($image);
    return $ret;
}

sub getChannel {
    my ($self,$image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_getChannel($image);
    return $ret;
}

sub getDepth {
    my ($self,$image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_getDepth($image);
    return $ret;
}

sub getWidthStep {
    my ($self,$image) = @_;
        if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_getWidthStep($image);
    return $ret;
}

sub getValueAt {
    my ($self,$image,$x,$y) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_getValueAt($image,$x,$y);
    return $ret;
}

sub copy {
    my ($self,$image) = @_;
    if( !defined($image) ){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_copy($image);
    return $ret;
}

sub trim {
    my ($self,$image, $left, $top, $width, $height) = @_;
    if( !defined($image) || !defined($left) || !defined($top) || !defined($width) || !defined($height)){
        croak('arguments undefined.');
    }
    my $ret = $self->xs_trim($image, $left, $top, $width, $height);
    return $ret;
}

sub detect {
    my ($self,$image,$cascadeFile) = @_;
    if( !defined($image) || !defined($cascadeFile) ){
        croak('arguments undefined.');
    }
    my $ret;
    if($self->cascadeCheck($cascadeFile) == 1){
        $ret = $self->xs_detect($image,$cascadeFile);
    }else{
        $ret = [];
    }
    wantarray ? @$ret : $ret;
}


sub showTwoImages{
    my ($self,$imageA,$nameA,$imageB,$nameB) = @_;
    my $ret = $self->xs_showTwoImages($imageA,$nameA,$imageB,$nameB);
}

sub showImage {
   my ($self, $img, $name) = @_;
   $self->xs_showImage($img, $name);
   return 1;
}

sub destroyWindow{
    my ($self,$name) = @_;
    $self->xs_destroyWindow($name);
}

sub destroyAllWindows{
    my ($self) = @_;
    $self->xs_destroyAllWindows();
}

sub getOutLine{
    my ($self, $input_file_name,$output_file_name) = @_;
    my $ret = $self->xs_getOutline($input_file_name,$output_file_name);
    return $ret;
}

sub trimming{
    my ($self, $input_file,$output_file,$width,$height) = @_;
    my $ret = $self->xs_edgeDetect($input_file->filename,$output_file->filename);
}

sub capture{
    my ($self) = @_;
    my $img = $self->xs_capture();
#    Image::OpenCV::Image->new($img);
}

sub trackingFaceOnMovie{
    my ($self, $cascade) = @_;
    $self->xs_trackingFaceOnMovie($cascade);
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

1;
