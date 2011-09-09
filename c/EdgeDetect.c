#include <cv.h>
#include <highgui.h>

int
main (int argc, char **argv)
{
  IplImage *src_img, *dst_img;
  IplImage *tmp_img;

  // (1)画像の読み込み
    src_img = cvLoadImage (argv[1], CV_LOAD_IMAGE_GRAYSCALE);

  tmp_img = cvCreateImage (cvGetSize (src_img), IPL_DEPTH_16S, 1);
  dst_img = cvCreateImage (cvGetSize (src_img), IPL_DEPTH_8U, 1);

  // (3)画像のLaplacianの作成
  cvLaplace (src_img, tmp_img);
  cvConvertScaleAbs (tmp_img, dst_img);

  // (5)画像の表示
  cvNamedWindow ("Original", CV_WINDOW_AUTOSIZE);
  cvShowImage ("Original", src_img);
  cvNamedWindow ("Laplace", CV_WINDOW_AUTOSIZE);
  cvShowImage ("Laplace", dst_img);
  cvWaitKey (0);

  cvDestroyWindow ("Original");
  cvDestroyWindow ("Laplace");
  cvReleaseImage (&src_img);
  cvReleaseImage (&dst_img);
  cvReleaseImage (&tmp_img);

  return 0;
}
