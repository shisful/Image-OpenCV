#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define NEED_newRV_noinc
#define NEED_sv_2pv_nolen
#include "ppport.h"
#include "cv.h"
#include "highgui.h"
#include "ctype.h"
#include "stdio.h"

MODULE = Image::OpenCV        PACKAGE = Image::OpenCV

PROTOTYPES: ENABLE

SV *
new(class)
        SV *class;
    PREINIT:
        SV *self;
    CODE:
        self = newSViv(1);
        self = newRV_noinc(self);

        sv_bless(self, gv_stashpv(SvPV_nolen(class), 1));
        RETVAL = self;
    OUTPUT:
        RETVAL

SV *
xs_createImage(self,width,height,IPL_DEPTH,Channel)
        SV *self;
        int width;
        int height;
        int IPL_DEPTH;
        int Channel;
    PREINIT:
        IplImage *img;
        SV *image;
    CODE:
        img = cvCreateImage(cvSize(width,height),IPL_DEPTH,Channel);
        image = newSViv(PTR2IV(img));
        image = newRV_noinc(image);
        RETVAL = image;
    OUTPUT:
        RETVAL

SV *
xs_loadImage(self,filename)
        SV *self;
        char *filename;
    PREINIT:
        IplImage *img;
        SV *image;
    CODE:
        img = cvLoadImage (filename, CV_LOAD_IMAGE_ANYDEPTH | CV_LOAD_IMAGE_ANYCOLOR);
        if(img){
            image = newSViv(PTR2IV(img));
            image = newRV_noinc(image);
            RETVAL = image;
        }else{
            RETVAL = newSVuv(0);
        }
    OUTPUT:
        RETVAL

SV *
xs_saveImage(self,filename,image)
        SV *self;
        char *filename;
        SV *image;
    PREINIT:
        IplImage *img;
        int i;
    CODE:
        img = INT2PTR(IplImage *, SvIV(SvRV(image)));
        int param[]={CV_IMWRITE_JPEG_QUALITY,100};
        i = cvSaveImage(filename, img, param);
        RETVAL = newSVuv(i);
    OUTPUT:
        RETVAL

SV *
xs_convertToGray(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *before,*after;
    CODE:
        before = INT2PTR(IplImage *, SvIV(SvRV(image)));
        after = cvCreateImage(cvSize(before->width,before->height),before->depth,1);
        if(before->nChannels == 1 ){
            cvCopy(before,after,NULL);
        }else{
            cvCvtColor ( before, after, CV_BGR2GRAY);
        }
        image = newSViv(PTR2IV(after));
        image = newRV_noinc(image);
        RETVAL = image;
    OUTPUT:
        RETVAL

void
xs_releaseImage(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *img;
    CODE:
        img = INT2PTR(IplImage *, SvIV(SvRV(image)));
        cvReleaseImage(&img);

SV *
xs_laplace(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *input,*tmp,*output,*gray;
        SV *outImage;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        gray = cvCreateImage (cvGetSize (input), IPL_DEPTH_8U, 1);
        if( input->nChannels == 3 ){
            cvCvtColor (input, gray, CV_BGR2GRAY);
        }else if(input->nChannels == 1){
            cvCopy(input, gray, NULL);
        }else{
           croak("Please load Gray-scale image");
        }
        tmp = cvCreateImage (cvGetSize (gray), IPL_DEPTH_16S, 1);
        output = cvCreateImage (cvGetSize (gray), IPL_DEPTH_8U, 1);
        cvLaplace (gray, tmp , 3);
        cvConvertScaleAbs (tmp, output, 1, 0);
        outImage = newSViv(PTR2IV(output));
        outImage = newRV_noinc(outImage);
        cvReleaseImage(&tmp);
        cvReleaseImage(&gray);


        RETVAL = outImage;
    OUTPUT:
        RETVAL

SV *
xs_canny(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *input,*output,*gray;
        SV *outImage;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
                gray = cvCreateImage (cvGetSize (input), IPL_DEPTH_8U, 1);
        if( input->nChannels == 3 ){
            cvCvtColor (input, gray, CV_BGR2GRAY);
        }else if(input->nChannels == 1){
            cvCopy(input, gray, NULL);
        }else{
           croak("Please load Gray-scale image");
        }
        output = cvCreateImage (cvGetSize (gray), IPL_DEPTH_8U, 1);
        cvCanny (gray, output, 50.0, 200.0, 3);

        cvReleaseImage(&gray);
        outImage = newSViv(PTR2IV(output));
        outImage = newRV_noinc(outImage);
        RETVAL = outImage;
    OUTPUT:
        RETVAL

SV *
xs_resize(self,image,width,height)
        SV *self;
        SV *image;
        int width;
        int height;
    PREINIT:
        IplImage *input,*output;
        SV *outImage;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        output = cvCreateImage( cvSize(width,height),input->depth, input->nChannels);
        cvResize(input,output,CV_INTER_CUBIC);
        outImage = newSViv(PTR2IV(output));
        outImage = newRV_noinc(outImage);
        RETVAL = outImage;
    OUTPUT:
        RETVAL

SV *
xs_getWidth(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *input;
        SV *outImage;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        RETVAL = newSVuv(input->width);
    OUTPUT:
        RETVAL

SV *
xs_getHeight(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *input;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        RETVAL = newSVuv(input->height);
    OUTPUT:
        RETVAL

SV *
xs_getChannel(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *input;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        RETVAL = newSVuv(input->nChannels);
    OUTPUT:
        RETVAL

SV *
xs_getDepth(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *input;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        RETVAL = newSVuv(input->depth);
    OUTPUT:
        RETVAL

SV *
xs_getWidthStep(self, image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *input;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        RETVAL = newSVuv(input->widthStep);
    OUTPUT:
        RETVAL

SV *
xs_getValueAt(self, image,x,y);
        SV *self;
        SV *image;
        int x;
        int y;
    PREINIT:
        IplImage *input;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        if( x < input->width && y< input->height ){
            int pos = input->widthStep * y + x*input->nChannels;
            RETVAL = newSVuv(input->imageData[pos]);
        }else{
            RETVAL = newSVuv(0);
        }
    OUTPUT:
        RETVAL



SV *
xs_copy(self,image)
        SV *self;
        SV *image;
    PREINIT:
        IplImage *original,*copy;
        SV *out;
    CODE:
        original = INT2PTR(IplImage *, SvIV(SvRV(image)));
        copy = cvCreateImage(cvSize(original->width, original->height), original->depth, original->nChannels);
        cvCopy( original, copy, NULL);
        out = newSViv(PTR2IV(copy));
        out = newRV_noinc(out);
        RETVAL = out;
    OUTPUT:
        RETVAL


SV *
xs_trim(self, image, left, top, width, height)
        SV *self;
        SV *image;
        int left;
        int top;
        int width;
        int height;
    PREINIT:
        CvRect trimRect;
        IplImage *input, *tmp, *output;
        SV *outImage;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        tmp = cvCreateImage(cvSize(input->width,input->height), input->depth, input->nChannels);
        cvCopy( input, tmp, NULL);
        trimRect = cvRect( left, top, width, height );
        output = cvCreateImage(cvSize(width, height), tmp->depth, tmp->nChannels);
        cvSetImageROI( tmp,trimRect );
        cvCopy( tmp, output, NULL);
        outImage = newSViv(PTR2IV(output));
        outImage = newRV_noinc(outImage);
        cvReleaseImage(&tmp);
        RETVAL = outImage;
    OUTPUT:
        RETVAL


SV *
xs_detect(self, image, cascadeFile)
        SV *self;
        SV *image;
        char *cascadeFile;
    PREINIT:
        IplImage *img, *gray;
        int i;
        CvMemStorage *storage;
        CvHaarClassifierCascade *cascade;
        CvSeq *objects;
        CvRect *rect;
        AV *retval;
        HV *hash;
    CODE:
        img = INT2PTR(IplImage *, SvIV(SvRV(image)));
        gray = cvCreateImage(cvSize(img->width, img->height), 8, 1);
        if(img->nChannels == 1){
            cvCopy(img,gray,NULL);
        }else{
            cvCvtColor(img, gray, CV_BGR2GRAY);
        }
        cvEqualizeHist(gray, gray);
        storage = cvCreateMemStorage(0);
        cascade = cvLoad(cascadeFile, 0, 0, 0);
        objects = cvHaarDetectObjects(gray, cascade, storage,
#if (CV_MAJOR_VERSION < 2 || (CV_MAJOR_VERSION == 2 && CV_MINOR_VERSION < 1))
                1.1, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0, 0));
#else
                1.1, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0, 0), cvSize(0, 0));
#endif
        retval = newAV();
        printf("objects = %d",objects->total);
        for (i = 0; i < (objects ? objects->total : 0); i++) {
            rect = (CvRect *) cvGetSeqElem(objects, i);
            hash = newHV();
            hv_store(hash, "x", 1, newSViv(rect->x), 0);
            hv_store(hash, "y", 1, newSViv(rect->y), 0);
            hv_store(hash, "width", 5, newSViv(rect->width), 0);
            hv_store(hash, "height", 6, newSViv(rect->height), 0);
            av_push(retval, newRV_noinc((SV *) hash));
        }
        RETVAL = newRV_noinc((SV *) retval);
        cvReleaseMemStorage(&storage);
        cvReleaseImage(&gray);
        cvReleaseHaarClassifierCascade(&cascade);

    OUTPUT:
        RETVAL


SV *
xs_trimming(self, inputFileName, outputFileName, width, height)
        SV *self;
        char *inputFileName;
        char *outputFileName;
        unsigned int width;
        unsigned int height;

    PREINIT:
        IplImage *inputImage, *outputImage, *resizeImage, *grayImage, *edgeImage;
        int isLongWidth;
        unsigned int x, y, i;
        unsigned int resizeWidth, resizeHeight;
        unsigned int left, top;
        unsigned long int sum, count, val;
        unsigned int limit_left, limit_right, limit_top, limit_bottom;
        unsigned int margin, goodFace;
        unsigned long int bestScore, score, area, position;
        double delta;
        unsigned int avr;
        double variance;
        double max_sum, var;
        CvHaarClassifierCascade *cascade;
        CvSeq *objects;
        CvRect *rect;
        CvRect trimRect;
        CvMemStorage *storage;
    CODE:
    inputImage = cvLoadImage(inputFileName, 1);
    if (!inputImage){
        RETVAL = newSVuv(0);
        return;
    }
        # リサイズ
        double scale;
        if( ((double)inputImage->height/inputImage->width) > ((double)height/width) ){
            isLongWidth = 0;
            resizeWidth = width;
            scale = (double)width/inputImage->width;
            resizeHeight = (unsigned int)(scale * inputImage->height);
        }else if (((double)inputImage->height/inputImage->width) < ((double)height/width)){
            isLongWidth = 1;
            resizeHeight = height;
            scale = (double)height/inputImage->height;
            resizeWidth = (unsigned int)(scale * inputImage->width);
        }else{
            isLongWidth = -1;
            resizeWidth = width;
            resizeHeight = height;
        }
        if( resizeWidth == width && resizeHeight == height ){
            isLongWidth = -1;
        }
        resizeImage = cvCreateImage( cvSize(resizeWidth,resizeHeight),IPL_DEPTH_8U, 3);
        cvResize(inputImage,resizeImage,CV_INTER_CUBIC);

            # トリミング場所の決定
        limit_top = resizeImage->height;
        limit_bottom = 0;
        limit_right = 0;
        limit_left = resizeImage->width;
                # エッジ画像を作成
        grayImage = cvCreateImage (cvGetSize (resizeImage), IPL_DEPTH_8U, 1);
        edgeImage = cvCreateImage (cvGetSize (resizeImage), IPL_DEPTH_8U, 1);
        cvCvtColor (resizeImage, grayImage, CV_BGR2GRAY);

                # cannyフィルタによるエッジ検出（2値化）
        cvCanny (grayImage, edgeImage, 50.0, 200.0, 3);

                # 顔検出
        cvEqualizeHist(grayImage, grayImage);
        storage = cvCreateMemStorage(0);
        cascade = INT2PTR(CvHaarClassifierCascade *, SvIV(SvRV(self)));
        objects = cvHaarDetectObjects(grayImage, cascade, storage,
#if (CV_MAJOR_VERSION < 2 || (CV_MAJOR_VERSION == 2 && CV_MINOR_VERSION < 1))
                1.1, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0, 0));
#else
        1.1, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0, 0), cvSize(0, 0));
#endif
        cvReleaseMemStorage(&storage);
                # 顔があった場合にそこは必ず入るようにlimitを与える
        margin = 30;
        goodFace = 0;
        bestScore = 0;
        if( objects->total > 0 ){
            for (i = 0; i < objects->total; i++) {
                rect = (CvRect *) cvGetSeqElem(objects, i);
                area = rect->width*rect->height;
                position = (grayImage->width - (rect->x + rect->width/2))*(grayImage->height - (rect->y + rect->height/2));
                score = area + position;
                if( bestScore < score ){
                    bestScore = score;
                    goodFace = i;
                }
            }
            rect = (CvRect *) cvGetSeqElem(objects, goodFace);

            if( rect->y - margin < 0 ){
                limit_top = 0;
            }else{
                limit_top = rect->y - margin;
            }
            if( rect->y + rect->height + margin > height ){
                limit_bottom = height;
            }else{
                limit_bottom = rect->y + rect->height + margin;
            }
            if( rect->x - margin < 0 ){
                limit_left = 0;
            }else{
                limit_left = rect->x - margin;
            }
            if( rect->x + rect->width + margin > width ){
                limit_right = height;
            }else{
                limit_right = rect->x + rect->width + margin;
            }
        }

        sum = 0;
        count = 0;
            # 縦長の場合
        if( isLongWidth == 0 ){
            left = 0;
            long double array[edgeImage->height];
            for (y = 0; y < edgeImage->height; y++){
                    # 平均を求める
                for (x = 0; x < edgeImage->width * edgeImage->nChannels; x++){
                    val = edgeImage->imageData[edgeImage->widthStep * y + x*edgeImage->nChannels];
                    count++;
                    if(val == 0){
                    }else{
                        sum = sum + x;
                    }
                }
                avr = (unsigned int)((double)sum/count);
                    # 分散を求める
                variance = 0.0;
                for (x = 0; x < edgeImage->width * edgeImage->nChannels; x++){
                    val = edgeImage->imageData[edgeImage->widthStep * y + x*edgeImage->nChannels];
                    if(val == 0){
                    }else{
                        delta = (double)avr - x;
                        delta = delta/edgeImage->width;
                        delta = delta*delta;
                        variance = variance + delta;
                    }
                }
                array[y] = variance;
            }
            max_sum = -1.0;
            int flag = 0;
            int roop = 0;
            while ( flag == 0 ){
               if(roop > 1){
                 printf("roop error\n");
                 flag = 1;
                 RETVAL = newSVuv(0);
                 return;
                }else{
                for (y = 0; y < edgeImage->height-height; y++){
                    var = 0.0;
                    if( y < limit_top && y+height > limit_bottom ){
                        for ( i = y; i < y+height; i++){
                            var = var + array[i];
                        }
                        if( max_sum < var ){
                            top = y;
                            max_sum = var;
                            flag = 1;
                        }
                    }
                }
                limit_top = height;
                limit_bottom = 0;
                roop++;
            }
            }

            # 横長の場合
        }else if(isLongWidth == 1){
            top = 0;
            double array[edgeImage->width];
            for (x = 0; x < edgeImage->width * edgeImage->nChannels; x++){
                # 平均を求める
                for (y = 0; y < edgeImage->height; y++){
                    val = edgeImage->imageData[edgeImage->widthStep * y + x*edgeImage->nChannels];
                    count++;
                    if(val == 0){
                    }else{
                        sum = sum + y;
                    }
                }
                avr = (unsigned int)((double)sum/count);
# 分散を求める
                variance = 0.0;
                for (y = 0; y < edgeImage->height; y++){
                    val = edgeImage->imageData[edgeImage->widthStep * y + x*edgeImage->nChannels];
                    if(val == 0){
                    }else{
                        delta = (double)avr - y;
                        delta = delta/edgeImage->height;
                        delta = delta*delta;
                        variance = variance + delta;
                    }
                }
                array[x] = variance;
            }
            max_sum = -1.0;
            int flag = 0;
            int roop = 0;
            while ( flag == 0 ){
                if(roop > 1){
                 printf("roop error\n");
                 flag = 1;
                 RETVAL = newSVuv(0);
                 return;
                }else{
                for (x = 0; x < edgeImage->width-width; x++){

                    var = 0.0;
                    if( x < limit_left && x+width > limit_right ){
                        for ( i = x; i < x+width; i++){
                            var = var + array[i];
                        }
                        if( max_sum < var ){
                            left = x;
                            max_sum = var;
                            flag = 1;
                        }
                    }
                }
                limit_left = width;
                limit_right = 0;
                roop++;
                }
            }
        }else if(isLongWidth == -1){
            top = 0;
            left = 0;
        }

            # 切り出し
        printf("top = %d , ", top);
        printf("left = %d\n", left);

        trimRect = cvRect( left, top, width, height );
        outputImage = cvCreateImage(cvSize(width, height), resizeImage->depth, resizeImage->nChannels);
        cvSetImageROI( resizeImage,trimRect );
        cvCopy( resizeImage, outputImage, NULL);
        cvSaveImage(outputFileName, outputImage, 0);
        cvReleaseImage(&resizeImage);
        cvReleaseImage(&grayImage);
        cvReleaseImage(&edgeImage);
        cvReleaseImage(&outputImage);
        cvReleaseImage(&inputImage);
        RETVAL = newSVuv(1);
    OUTPUT:
        RETVAL


SV *
xs_getOutline(self, inputFileName, outputFileName)
        SV *self;
        char *inputFileName;
        char *outputFileName;
    PREINIT:
        IplImage *imgA, *gray;
    CODE:
        imgA = cvLoadImage( inputFileName, CV_LOAD_IMAGE_ANYDEPTH | CV_LOAD_IMAGE_ANYCOLOR);
        if(!imgA){
        }else{
            gray = cvCreateImage(cvGetSize(imgA),IPL_DEPTH_8U,1);
            cvCvtColor(imgA, gray, CV_BGR2GRAY);
            cvThreshold(gray,gray,127,255,CV_THRESH_BINARY);
            cvNamedWindow("gray",CV_WINDOW_AUTOSIZE);
            cvShowImage("gray",gray);

            CvMemStorage *storage = cvCreateMemStorage (0);
            CvSeq *contours = 0;
            int x = cvFindContours (gray, storage, &contours, sizeof (CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0,0));
            printf("輪郭が %d 個見つかりました\n",x);
            cvDrawContours (imgA, contours, CV_RGB (255, 0, 0), CV_RGB (0, 255, 0), 1,1, CV_AA, cvPoint(0,0));

            cvNamedWindow("window",CV_WINDOW_AUTOSIZE);
            cvShowImage("window",imgA);

            cvWaitKey(0);
            cvDestroyWindow("gray");

            cvDestroyWindow("window");
            cvReleaseMemStorage (&storage);
            cvReleaseImage( & gray);


            cvReleaseImage( & imgA);

        }
        RETVAL = newSVuv(1);
    OUTPUT:
        RETVAL


void
xs_showTwoImages(self,imageA,nameA,imageB,nameB)
        SV *self;
        SV *imageA;
        char *nameA;
        SV *imageB;
        char *nameB;
    PREINIT:
        IplImage *imgA, *imgB;
    CODE:
        imgA = INT2PTR(IplImage *, SvIV(SvRV(imageA)));
        imgB = INT2PTR(IplImage *, SvIV(SvRV(imageB)));
        cvNamedWindow(nameA,CV_WINDOW_AUTOSIZE);
        cvNamedWindow(nameB,CV_WINDOW_AUTOSIZE);
        cvMoveWindow(nameA,0,0);
        cvMoveWindow(nameB,imgA->width,0);
        cvShowImage(nameA,imgA);
        cvShowImage(nameB,imgB);

void
xs_showThreeImages(self,image1,windowName1,image2,windowName2,image3,windowName3)
        SV *self;
        SV *image1;
        char *windowName1;
        SV *image2;
        char *windowName2;
        SV *image3;
        char *windowName3;
    PREINIT:
        IplImage *img1, *img2, *img3;
    CODE:
        img1 = INT2PTR(IplImage *, SvIV(SvRV(image1)));
        img2 = INT2PTR(IplImage *, SvIV(SvRV(image2)));
        img3 = INT2PTR(IplImage *, SvIV(SvRV(image3)));
        cvNamedWindow(windowName1,CV_WINDOW_AUTOSIZE);
        cvNamedWindow(windowName2,CV_WINDOW_AUTOSIZE);
        cvNamedWindow(windowName3,CV_WINDOW_AUTOSIZE);
        cvMoveWindow(windowName1,0,0);
        cvMoveWindow(windowName2,img1->width,0);
        cvMoveWindow(windowName3,img1->width+img2->width,0);
        cvShowImage(windowName1,img1);
        cvShowImage(windowName2,img2);
        cvShowImage(windowName3,img3);


void
xs_destroyWindow(self, name)
        SV *self;
        char *name;
    PREINIT:
    CODE:
        cvDestroyWindow (name);

void
xs_destroyAllWindows(self)
        SV *self;
    PREINIT:
    CODE:
        cvDestroyAllWindows();

SV *
xs_showImage(self,image,name)
        SV *self;
        SV *image;
        char *name;
    PREINIT:
        IplImage *img;
    CODE:
        img = INT2PTR(IplImage *, SvIV(SvRV(image)));
        cvNamedWindow(name,CV_WINDOW_AUTOSIZE);
        cvShowImage(name,img);
        RETVAL = newSVuv(1);
    OUTPUT:
        RETVAL

SV *
xs_backgroundCheck(self,image,mode)
        SV *self;
        SV *image;
        int mode;
    PREINIT:
        IplImage *input,*gray;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        gray = cvCreateImage (cvGetSize (input), IPL_DEPTH_8U, 1);
        if( input->nChannels == 3 ){
            cvCvtColor (input, gray, CV_BGR2GRAY);
        }else if(input->nChannels == 1){
            cvCopy(input, gray, NULL);
        }else{
            croak("Please load Gray-scale image");
        }
        unsigned char val;
        unsigned int sum = 0;
        int count = 0;
        int x, i, y;

        for( x = 0 ; x < gray->width * gray->nChannels; x++ ){
            for( i = 0 ; i < 5 ; i++){
                val = gray->imageData[gray->widthStep * i + x * gray->nChannels];
                count++;
                sum = sum + val;
                val = gray->imageData[gray->widthStep * (gray->height - 1 - i) + x * gray->nChannels];
                count++;
                sum = sum + val;
            }
        }
        for( y = 0 ; y < gray->height; y++){
            for( i = 0 ; i < 5 ; i++){
                val = gray->imageData[gray->widthStep * y + i * gray->nChannels];
                count++;
                sum = sum + val;
                val = gray->imageData[gray->widthStep * y + (gray->width - i - 1) * gray->nChannels];
                count++;
                sum = sum + val;
            }
            double d = sum/count;
            if( mode == 0 ) {
                if( d < 5 ){
                    RETVAL = newSVuv(1);
                }else{
                    RETVAL = newSVuv(0);
                }
            }else{
                if( d > 250 ){
                    RETVAL = newSVuv(1);
                }else{
                    RETVAL = newSVuv(0);
                }
            }
        }
        cvReleaseImage(&gray);
    OUTPUT:
        RETVAL

SV *
xs_addWhite(self,image,length,mode)
        SV *self;
        SV *image;
        int length;
        int mode;
    PREINIT:
        IplImage *input, *output;
        SV *outImage;
    CODE:
        input = INT2PTR(IplImage *, SvIV(SvRV(image)));
        int channel = input->nChannels;
        if(channel == 4){
            channel = 3;
        }
        #上下を埋める場合
        if( mode == 0 ){
            output = cvCreateImage (cvSize (input->width, length), input->depth, channel);
        }else{
            output = cvCreateImage (cvSize (length, input->height), input->depth, channel);
        }
        unsigned int arraySize = output->width * output->height * output->nChannels;
        int i;
        for( i = 0; i < arraySize; i++){
            output->imageData[i] = 255;
        }

        int x, y;
        int outputPosition;
        int inputPosition;
        int c;
        for( x = 0 ; x < input->width; x++ ){
            for( y = 0 ; y < input->height ; y++){
                inputPosition = input->widthStep*y + x*input->nChannels;
                if( mode == 0 ){
                    outputPosition = (output->widthStep)*(y+ (length - input->height)*2/3) + x*output->nChannels;
                }else{
                    outputPosition = output->widthStep*y + ( x + (length - input->height)/2)*output->nChannels;
                }
                for( c = 0;c < output->nChannels;c++ ){
                    output->imageData[outputPosition + c] = input->imageData[inputPosition + c];
                }
            }
        }

        outImage = newSViv(PTR2IV(output));
        outImage = newRV_noinc(outImage);
        RETVAL = outImage;
    OUTPUT:
        RETVAL

SV *
xs_capture(self)
        SV *self;
    PREINIT:
        IplImage *input, *output;
        SV *outImage;
        CvCapture *capture = 0;
    CODE:
        int c;
        capture = cvCreateCameraCapture(0);
        cvNamedWindow("Capture", CV_WINDOW_AUTOSIZE);
        while (1) {
            input = cvQueryFrame(capture);
            cvShowImage("Capture", input);
            c = cvWaitKey(33);
            if (c == 0x1b) {
                RETVAL = newSVuv(0);
                break;
            } else if (c == 0x73) {
                output = cvCreateImage(cvSize(input->width,input->height),input->depth,input->nChannels);
                cvCopy(input, output, NULL);
                outImage = newSViv(PTR2IV(output));
                outImage = newRV_noinc(outImage);
                RETVAL = outImage;
                break;
            }
        }
        cvReleaseCapture(&capture);
        cvDestroyWindow("Capture");
    OUTPUT:
        RETVAL


void
xs_trackingFaceOnMovie(self,cascadeFile)
        SV *self;
        char *cascadeFile;
    PREINIT:
        IplImage *input, *gray;
        SV *outImage;
        CvCapture *capture = 0;
        int i;
        CvMemStorage *storage;
        CvHaarClassifierCascade *cascade;
        CvSeq *objects;
    CODE:
        CvScalar colors[] =
    {
        {{0,0,255}},
        {{0,128,255}},
        {{0,255,255}},
        {{0,255,0}},
        {{255,128,0}},
        {{255,255,0}},
        {{255,0,0}},
        {{255,0,255}}
    };
        double scale = 1.0;
        int c;
        capture = cvCreateCameraCapture(0);
        cvNamedWindow("Capture", CV_WINDOW_AUTOSIZE);
        while (1) {
            input = cvQueryFrame(capture);
        gray = cvCreateImage(cvSize(input->width, input->height), 8, 1);
        if(input->nChannels == 1){
            cvCopy(input,gray,NULL);
        }else{
            cvCvtColor(input, gray, CV_BGR2GRAY);
        }
        cvEqualizeHist(gray, gray);
        storage = cvCreateMemStorage(0);
        cascade = cvLoad(cascadeFile, 0, 0, 0);
        objects = cvHaarDetectObjects(gray, cascade, storage,
#if (CV_MAJOR_VERSION < 2 || (CV_MAJOR_VERSION == 2 && CV_MINOR_VERSION < 1))
                1.1, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0, 0));
#else
                1.1, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0, 0), cvSize(0, 0));
#endif

        for( i = 0; i < (objects ? objects->total : 0); i++ ){
            CvRect* r = (CvRect*)cvGetSeqElem( objects, i );
            CvPoint center;
            int radius;
            center.x = cvRound((r->x + r->width*0.5)*scale);
            center.y = cvRound((r->y + r->height*0.5)*scale);
            radius = cvRound((r->width + r->height)*0.25*scale);
            cvCircle( input, center, radius, colors[i%8], 3, 8, 0 );
        }
            cvShowImage("Capture", input);
            c = cvWaitKey(33);
            if (c == 0x1b) {
                break;
            }
        }
        cvReleaseCapture(&capture);
        cvDestroyWindow("Capture");


void
DESTROY(self)
        SV *self;
    PREINIT:
    CODE:

