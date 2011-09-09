include <cv.h>
#include <highgui.h>
#include "BlobResult.h"

SV *
xs_labelling(self, inputFIleName, outputFileName)
    SV *self;
    char *filename;
    char *outputFileName;
PREINIT:
    IplImage *src_img, *dst_img;
    int sum_x, sum_y, x, y, count;
    double variance_x, variance_y, avr_x, avr_y;
    double *pdImg;
    double delta;
    
    int val;
    uchar *pSrc, *pDst;
    CvMemStorage *storage;
    CvHaarClassifierCascade *cascade;
    CvSeq *objects;
    CvRect *rect;
    AV *retval;
    HV *hash;
    CBlobResult blobs;
CBlob blob;
CvFont font;
CBlob blobWithBiggestPerimeter, blobWithLessArea;

CODE:
    int i;
    CvPoint p1, p2;
    char text[64];
    
    src_img = cvLoadImage (inputFileName, CV_LOAD_IMAGE_COLOR)
    dst_img = cvCreateImage (cvSize (src_img->width, src_img->height), IPL_DEPTH_8U, 1);
    cvCvtColor (src_img, dst_img, CV_BGR2GRAY);
    cvInitFont (&font, CV_FONT_HERSHEY_SIMPLEX, 0.5, 0.5, 0, 1, CV_AA);
    
    blobs = CBlobResult (dst_img, NULL, 100, false);
    
    blobs.Filter (blobs, B_INCLUDE, CBlobGetArea (), B_INSIDE, 1000, 50000);
    
    for (i = 0; i < blobs.GetNumBlobs (); i++) {
        blob = blobs.GetBlob (i);
        p1.x = (int) blob.MinX ();
        p1.y = (int) blob.MinY ();
        p2.x = (int) blob.MaxX ();
        p2.y = (int) blob.MaxY ();
        
        cvRectangle (src_img, p1, p2, CV_RGB (255, 0, 0), 2, 8, 0);
        sprintf (text, "[%d] %d,%d", blob.Label (), (int) blob.area, (int) blob.Perimeter ());
        cvPutText (src_img, text, cvPoint (p1.x, p1.y - 5), &font, cvScalarAll (255));
    }
    
    blobs.GetNthBlob (CBlobGetPerimeter (), 0, blobWithBiggestPerimeter);
    blobWithBiggestPerimeter.FillBlob (src_img, CV_RGB (0, 255, 0));
    
    blobs.GetNthBlob (CBlobGetArea (), blobs.GetNumBlobs () - 1, blobWithLessArea);
    blobWithLessArea.FillBlob (src_img, CV_RGB (0, 0, 255));

    cvNamedWindow ("Labeling", CV_WINDOW_AUTOSIZE);
    cvShowImage ("Labeling", src_img);
    cvWaitKey (0);
    
    cvDestroyWindow ("Labeling");
    cvReleaseImage (&src_img);
    cvReleaseImage (&dst_img);
    
    return 0;
}