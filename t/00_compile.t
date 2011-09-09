use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Image::OpenCV');
    use_ok('Image::OpenCV::Image');
    can_ok('Image::OpenCV', 'xs_createImage');
    can_ok('Image::OpenCV', 'xs_loadImage');
    can_ok('Image::OpenCV', 'xs_saveImage');
    can_ok('Image::OpenCV', 'xs_convertToGray');
    can_ok('Image::OpenCV', 'xs_releaseImage');
    can_ok('Image::OpenCV', 'xs_laplace');
    can_ok('Image::OpenCV', 'xs_canny');
    can_ok('Image::OpenCV', 'xs_resize');
    can_ok('Image::OpenCV', 'xs_getWidth');
    can_ok('Image::OpenCV', 'xs_getHeight');
    can_ok('Image::OpenCV', 'xs_getChannel');
    can_ok('Image::OpenCV', 'xs_getDepth');
    can_ok('Image::OpenCV', 'xs_getWidthStep');
    can_ok('Image::OpenCV', 'xs_getValueAt');
    can_ok('Image::OpenCV', 'xs_copy');
    can_ok('Image::OpenCV', 'xs_trim');
    can_ok('Image::OpenCV', 'xs_detect');
    can_ok('Image::OpenCV', 'xs_addWhite');
    can_ok('Image::OpenCV', 'xs_backgroundCheck');
}
done_testing;
