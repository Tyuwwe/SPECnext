message(STATUS "Generating build files for 525.x264_r...")

set(SRC_FILE_525_X264 src/x264_src/common/mdate.c
                      src/x264_src/output/raw.c
                      src/x264_src/common/rectangle.c
                      src/x264_src/encoder/lookahead.c
                      src/x264_src/input/yuv.c
                      src/x264_src/common/vlc.c
                      src/x264_src/input/y4m.c
                      src/x264_src/output/matroska.c
                      src/x264_src/common/cabac.c
                      src/x264_src/output/flv.c
                      src/x264_src/extras/getopt.c
                      src/x264_src/common/cpu.c
                      src/x264_src/input/thread.c
                      src/x264_src/common/quant.c
                      src/x264_src/output/flv_bytestream.c
                      src/x264_src/input/timecode.c
                      src/x264_src/common/frame.c
                      src/x264_src/common/mvpred.c
                      src/x264_src/common/set.c
                      src/x264_src/encoder/cabac.c
                      src/x264_src/output/matroska_ebml.c
                      src/x264_src/common/common.c
                      src/x264_src/x264.c
                      src/x264_src/encoder/macroblock.c
                      src/x264_src/common/predict.c
                      src/x264_src/common/deblock.c
                      src/x264_src/encoder/cavlc.c
                      src/x264_src/common/dct.c
                      src/x264_src/common/macroblock.c
                      src/x264_src/encoder/set.c
                      src/x264_src/common/mc.c
                      src/x264_src/encoder/ratecontrol.c
                      src/x264_src/encoder/me.c
                      src/x264_src/common/pixel.c
                      src/x264_src/encoder/encoder.c
                      src/x264_src/encoder/analyse.c)

set(525_X264_INCLUDE_DIR src/x264_src/inc src/x264_src src/x264_src/extras src/x264_src/common)

add_library(x264_r SHARED ${SRC_FILE_525_X264})
target_compile_definitions(x264_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_AUTO_BYTEORDER=0x12345678
    -DSPEC_LP64)
target_include_directories(x264_r PUBLIC ${525_X264_INCLUDE_DIR})
target_compile_options(x264_r PRIVATE -fcommon)
set_source_files_properties(${SRC_FILE_525_X264} PROPERTIES LANGUAGE C)

add_library(imagevalidate_525 SHARED src/image_validator/ImageValidator.c)
