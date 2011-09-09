package SmartTrim;

use strict;
use warnings;
use Image::OpenCV;
use Data::Dumper;

my $CASCADE_FILE = '/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml';#get_app_config('opencv_cascade_file') || '/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml';

sub new{
    my $pkg = shift;
    bless{},$pkg;
}

sub smart_trimmed_image {
    my ($self, $input_image, $width, $height) = @_;
    my $cv = Image::OpenCV->new();
    #my $input_image = $cv->newImage() or return;

    my $want_aspect_ratio = $height/$width;
    my $input_aspect_ratio = $self->get_aspect_ratio($input_image);

    my $is_width_longer = $self->check_aspect($input_aspect_ratio,$want_aspect_ratio);
    my $resize_image;
    my $output_image;
    if( $input_image->checkBackground(1) ){
        if($is_width_longer){
            $resize_image = $self->resize($input_image,0,$width,$height);
            $output_image = $resize_image->addWhite($height, 0);
        }else{
            $resize_image = $self->resize($input_image,1,$width,$height);
            $resize_image->show();
                        my $str = <STDIN>;

            $output_image = $resize_image->addWhite($width, 1);
        }
    }else{

    $resize_image = $self->resize($input_image,$is_width_longer,$width,$height);
    my $resize_image_aspect_ratio = $self->get_aspect_ratio($resize_image);
    $is_width_longer = $self->check_aspect($resize_image_aspect_ratio,$want_aspect_ratio);

                    # トリミング場所の決定
    my $limit = {
        top => $resize_image->height,
        bottom => 0,
        right => 0,
        left => $resize_image->width,
    };
                        # 顔検出 -- 顔があった場合にそこは必ず入るようにlimitを与える
    my $cascade = $CASCADE_FILE;
    my @faces = $resize_image->detect($cascade);
    my $length = @faces;
    if( $length > 0 ){
        my $good_face = $self->get_best_face(0.5, $resize_image->width, $resize_image->height, @faces);
        my $margin = 30;
        $limit = $self->get_limit($good_face, $margin, $resize_image->width, $resize_image->height);
    }

                        # エッジ画像を作成
    my $edge_image = $resize_image->canny();

    my $trim_position = $self->get_best_trim_position($is_width_longer, $edge_image, $limit, $width, $height);

                    # 切り出し
    print "top = $trim_position->{top}\n";
    print "left = $trim_position->{left}\n";
    $output_image = $resize_image->trim($trim_position->{left}, $trim_position->{top}, $width, $height);
    }
    return $output_image;
#    $output_image->saveImage($trim_image_file->filename);
#    return $trim_image_file;
}

sub smart_trimmed_image_new {
    my ($self, $input_image, $width, $height) = @_;
    my $cv = Image::OpenCV->new();
    #my $input_image = $cv->newImage() or return;

    my $want_aspect_ratio = $height/$width;
    my $input_aspect_ratio = $self->get_aspect_ratio($input_image);

    my $is_width_longer = $self->check_aspect($input_aspect_ratio,$want_aspect_ratio);
    my $resize_image;
    my $output_image;
    if( $input_image->checkBackground(1) ){
        if($is_width_longer){
            $resize_image = $self->resize($input_image,0,$width,$height);
            $output_image = $resize_image->addWhite($height, 0);
        }else{
            $resize_image = $self->resize($input_image,1,$width,$height);
            $resize_image->show();
                        my $str = <STDIN>;

            $output_image = $resize_image->addWhite($width, 1);
        }
    }else{

    $resize_image = $self->resize($input_image,$is_width_longer,$width,$height);
    my $resize_image_aspect_ratio = $self->get_aspect_ratio($resize_image);
    $is_width_longer = $self->check_aspect($resize_image_aspect_ratio,$want_aspect_ratio);

                    # トリミング場所の決定
    my $limit = {
        top => $resize_image->height,
        bottom => 0,
        right => 0,
        left => $resize_image->width,
    };
                        # 顔検出 -- 顔があった場合にそこは必ず入るようにlimitを与える
    my $cascade = $CASCADE_FILE;
    my @faces = $resize_image->detect($cascade);
    my $length = @faces;
    if( $length > 0 ){
        my $good_face = $self->get_best_face_new(0.5, $resize_image->width, $resize_image->height, @faces);
        my $margin = 30;
        $limit = $self->get_limit($good_face, $margin, $resize_image->width, $resize_image->height);
    }

                        # エッジ画像を作成
    my $edge_image = $resize_image->canny();

    my $trim_position = $self->get_best_trim_position_new($is_width_longer, $edge_image, $limit, $width, $height);

                    # 切り出し
    print "top = $trim_position->{top}\n";
    print "left = $trim_position->{left}\n";
    $output_image = $resize_image->trim($trim_position->{left}, $trim_position->{top}, $width, $height);
    }
    return $output_image;
#    $output_image->saveImage($trim_image_file->filename);
#    return $trim_image_file;
}


sub get_aspect_ratio {
    my ($self, $image) = @_;
    my $width = $image->width;
    my $height = $image->height;
    my $ret = $height/$width;
}

sub check_aspect {
    my ($self,$aspect_a,$aspect_b) = @_;
    my $is_width_longer;
    if( $aspect_a > $aspect_b ){
        $is_width_longer = 0;
    }elsif ($aspect_a < $aspect_b){
        $is_width_longer = 1;
    }else{
        $is_width_longer = -1;
    }
}

sub resize {
    my ($self, $image, $is_long_width, $width, $height) = @_;
    my $resize_width;
    my $resize_height;
    if( $is_long_width == 0 ){
        $resize_width = $width;
        $resize_height = $resize_width * $image->height/$image->width;
    }elsif ( $is_long_width == 1 ){
        $resize_height = $height;
        $resize_width = $resize_height * $image->width/$image->height;
    }else{
        $resize_width = $width;
        $resize_height = $height;
    }
    my $resizeImage = $image->resize( $resize_width,$resize_height);
}

sub get_best_face {
    my ($self, $alpha, $width, $height, @faces) = @_;
    my $best_score = 0;
    my $best_face;
    foreach my $face ( @faces ) {
        my $area = $face->{width} * $face->{height};
        my $position = ($width - ($face->{x} + $face->{width}/2))*($height - ($face->{y} + $face->{height}/2));
        my $score = $alpha*$area + (1-$alpha)*$position;
        if( $best_score < $score ){
            $best_score = $score;
            $best_face = $face;
        }
    }
    return $best_face;
}

sub get_best_face_new {
    my ($self, $alpha, $width, $height, @faces) = @_;
    my $best_score = 0;
    my $best_face;
    foreach my $face ( @faces ) {
        my $area = $face->{width} * $face->{height};
        my $position = ($height - ($face->{y} + $face->{height}/2))*($height - ($face->{y} + $face->{height}/2));
        my $score = $alpha*$area + (1-$alpha)*$position;
        if( $best_score < $score ){
            $best_score = $score;
            $best_face = $face;
        }
    }
    return $best_face;
}

sub get_limit {
    my ($self, $face, $margin, $width, $height) = @_;
    my $limit = {};
    if( $face->{y} - $margin < 0 ){
        $limit->{top} = 0;
    }else{
        $limit->{top} = $face->{y} - $margin;
    }
    if( $face->{y} + $face->{height} + $margin > $height ){
        $limit->{bottom} = $height;
    }else{
        $limit->{bottom} = $face->{y} + $face->{height} + $margin;
    }
    if( $face->{x} - $margin < 0 ){
        $limit->{left} = 0;
    }else{
        $limit->{left} = $face->{x} - $margin;
    }
    if( $face->{x} + $face->{width} + $margin > $width ){
        $limit->{right} = $height;
    }else{
        $limit->{right} = $face->{x} + $face->{width} + $margin;
    }
    return $limit;
}

sub get_best_trim_position {
    my ($self, $is_width_longer, $image, $limit, $width, $height) = @_;
    my $trim_position = {
        left => 0,
        top => 0
    };
    if( $is_width_longer == 0 ){
        $trim_position->{left} = 0;
        my @array;
        for (my $y = 0; $y < $image->height; $y++){
                        # 平均を求める
            my $sum = 0;
            my $count = 0;
            for (my $x = 0; $x < $image->width; $x++){
                my $val = $image->valueAt($x,$y);
                $count++;
                if($val != 0){
                     $sum = $sum + $x;
                }
            }
            my $avr = $sum/$count;
                        # 分散を求める
            my $variance = 0.0;
            for (my $x = 0; $x < $image->width; $x++){
                my $val = $image->valueAt($x, $y);
                if($val != 0){
                    my $delta = $avr - $x;
                    $delta = $delta/$image->width;
                    $delta = $delta*$delta;
                    $variance = $variance + $delta;
                }
            }
            $array[$y] = $variance;
        }
        my $max_sum = 0;
        my $roop = 0;
        while ( $max_sum == 0 ){
           if($roop > 1){
               print "roop error\n";
               $max_sum = 1;
               return 0;
            }else{
                for (my $y = 0; $y < $image->height-$height; $y++){
                    my $var = 0.0;
                    if( $y < $limit->{top} && $y+$height > $limit->{bottom} ){
                        for (my $i = $y; $i < $y + $height; $i++ ){
                            $var = $var + $array[$i];
                        }
                        if( $max_sum < $var ){
                            $trim_position->{top} = $y;
                            $max_sum = $var;
                       }
                    }
                }
                $limit->{top} = $height;
                $limit->{bottom} = 0;
                $roop++;
            }
        }
                # 横長の場合
    }elsif($is_width_longer == 1){
        $trim_position->{top} = 0;
        my @array;
        for (my $x = 0; $x < $image->width; $x++){
            my $count = 0;
            my $sum = 0;
                    # 平均を求める
            for (my $y = 0; $y < $image->height; $y++){
                my $val = $image->valueAt($x,$y);
                $count++;
                if($val != 0){
                    $sum = $sum + $y;
                }
            }
            my $avr = $sum/$count;
    # 分散を求める
            my $variance = 0.0;
            for (my $y = 0; $y < $image->height; $y++){
                my $val = $image->valueAt($x,$y);
                if($val != 0){
                    my $delta = $avr - $y;
                    $delta = $delta/$image->height;
                    $delta = $delta*$delta;
                    $variance = $variance + $delta;
                }
            }
            $array[$x] = $variance;
        }
        my $max_sum = 0;
        my $roop = 0;
        while ( $max_sum == 0 ){
            if($roop > 1){
                 print "roop error\n";
                 return 0;
            }else{
                for (my $x = 0; $x < $image->width-$width; $x++){
                    my $var = 0.0;
                    if( $x < $limit->{left} && $x+$width > $limit->{right} ){
                        for (my $i = $x; $i < $x+$width; $i++){
                            $var = $var + $array[$i];
                        }
                        if( $max_sum < $var ){
                            $trim_position->{left} = $x;
                            $max_sum = $var;
                        }
                    }
                }
                $limit->{left} = $width;
                $limit->{right} = 0;
                $roop++;
            }
        }
    }
    return $trim_position;
}

sub get_best_trim_position_new {
    my ($self, $is_width_longer, $image, $limit, $width, $height) = @_;
    my $trim_position = {
        left => 0,
        top => 0
    };
    if( $is_width_longer == 0 ){
        $trim_position->{left} = 0;
        my @array;
        for (my $y = 0; $y < $image->height; $y++){
                        # 平均を求める
            my $sum = 0;
            my $count = 0;
            for (my $x = 0; $x < $image->width; $x++){
                my $val = $image->valueAt($x,$y);
                $count++;
                if($val != 0){
                     $sum = $sum + $x;
                }
            }
            my $avr = $sum/$count;
                        # 分散を求める
            my $variance = 0.0;
            for (my $x = 0; $x < $image->width; $x++){
                my $val = $image->valueAt($x, $y);
                if($val != 0){
                    my $delta = $avr - $x;
                    $delta = $delta/$image->width;
                    $delta = $delta*$delta;
                    $variance = $variance + $delta;
                }
            }
            $array[$y] = $variance;
        }
        my $max_sum = 0;
        my $min_sum = 100000;
        my $roop = 0;
        my @array_val;
        my @array_pos;
        my $array_count = 0;
        while ( $max_sum == 0 ){
           if($roop > 1){
               print "roop error\n";
               $max_sum = 1;
               return 0;
            }else{
                for (my $y = 0; $y < $image->height-$height; $y++){
                    my $var = 0.0;
                    if( $y < $limit->{top} && $y+$height > $limit->{bottom} ){
                        for (my $i = $y; $i < $y + $height; $i++ ){
                            $var = $var + $array[$i];
                        }
                        $array_val[$array_count] = $var;
                        $array_pos[$array_count] = $y;
                        $array_count++;
                        if( $max_sum < $var ){
                            $max_sum = $var;
                        }
                        if( $min_sum > $var ){
                            $min_sum = $var;
                        }
                    }
                }
                $limit->{top} = $height;
                $limit->{bottom} = 0;
                $roop++;
            }
        }

        my $threshold;
        my $d = ($max_sum - $min_sum)/6;
        my $array_length = @array_val;

        for( my $i = 0;$i<$array_length;$i++){
            my $val = $array_val[$i];
            for( my $j = 1; $j < 6 ;$j++ ){
                if( $val < $min_sum + $j*$d ){
                    $array_val[$i] = $min_sum + ($j-1)*$d;
                    last;
                }
            }
        }
        my $max = 0;
        my $y;
        for( my $i = 0;$i<$array_length;$i++){
            if( $array_val[$array_length - $i - 1] > $max ){
                $y = $array_pos[$array_length - $i - 1];
            }
        }
        $trim_position->{top} = $y;       # 横長の場合
    }elsif($is_width_longer == 1){
        $trim_position->{top} = 0;
        my @array;
        for (my $x = 0; $x < $image->width; $x++){
            my $count = 0;
            my $sum = 0;
                    # 平均を求める
            for (my $y = 0; $y < $image->height; $y++){
                my $val = $image->valueAt($x,$y);
                $count++;
                if($val != 0){
                    $sum = $sum + $y;
                }
            }
            my $avr = $sum/$count;
    # 分散を求める
            my $variance = 0.0;
            for (my $y = 0; $y < $image->height; $y++){
                my $val = $image->valueAt($x,$y);
                if($val != 0){
                    my $delta = $avr - $y;
                    $delta = $delta/$image->height;
                    $delta = $delta*$delta;
                    $variance = $variance + $delta;
                }
            }
            $array[$x] = $variance;
        }
        my $max_sum = 0;
        my $roop = 0;
        while ( $max_sum == 0 ){
            if($roop > 1){
                 print "roop error\n";
                 return 0;
            }else{
                for (my $x = 0; $x < $image->width-$width; $x++){
                    my $var = 0.0;
                    if( $x < $limit->{left} && $x+$width > $limit->{right} ){
                        for (my $i = $x; $i < $x+$width; $i++){
                            $var = $var + $array[$i];
                        }
                        if( $max_sum < $var ){
                            $trim_position->{left} = $x;
                            $max_sum = $var;
                        }
                    }
                }
                $limit->{left} = $width;
                $limit->{right} = 0;
                $roop++;
            }
        }
    }
    return $trim_position;
}


1;