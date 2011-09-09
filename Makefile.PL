use strict;
use warnings;
use ExtUtils::MakeMaker;

link("lib/Image/OpenCV.xs", "OpenCV.xs");
chomp(my $libs    = `pkg-config opencv --libs`);
chomp(my $ccflags = `pkg-config opencv --cflags`);
die "cannot find opencv library." unless $libs;
$ccflags .= '-Isrc '.$ccflags;
WriteMakefile(
    NAME                => 'Image::OpenCV',
    AUTHOR              => 'Soichiro Hayashi',
    VERSION_FROM        => 'lib/Image/OpenCV.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0.32,
    },
    LIBS                => $libs,
    CCFLAGS             => $ccflags,
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Image-OpenCV-*' },
);

