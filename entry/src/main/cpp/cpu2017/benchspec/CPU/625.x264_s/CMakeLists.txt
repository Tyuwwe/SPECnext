message(STATUS "Generating build files for 625.x264_s...")

set(SRC_FILE_625_X264 ../525.x264_r/src/x264_src/common/mdate.c
                      ../525.x264_r/src/x264_src/output/raw.c
                      ../525.x264_r/src/x264_src/common/rectangle.c
                      ../525.x264_r/src/x264_src/encoder/lookahead.c
                      ../525.x264_r/src/x264_src/input/yuv.c
                      ../525.x264_r/src/x264_src/common/vlc.c
                      ../525.x264_r/src/x264_src/input/y4m.c
                      ../525.x264_r/src/x264_src/output/matroska.c
                      ../525.x264_r/src/x264_src/common/cabac.c
                      ../525.x264_r/src/x264_src/output/flv.c
                      ../525.x264_r/src/x264_src/extras/getopt.c
                      ../525.x264_r/src/x264_src/common/cpu.c
                      ../525.x264_r/src/x264_src/input/thread.c
                      ../525.x264_r/src/x264_src/common/quant.c
                      ../525.x264_r/src/x264_src/output/flv_bytestream.c
                      ../525.x264_r/src/x264_src/input/timecode.c
                      ../525.x264_r/src/x264_src/common/frame.c
                      ../525.x264_r/src/x264_src/common/mvpred.c
                      ../525.x264_r/src/x264_src/common/set.c
                      ../525.x264_r/src/x264_src/encoder/cabac.c
                      ../525.x264_r/src/x264_src/output/matroska_ebml.c
                      ../525.x264_r/src/x264_src/common/common.c
                      ../525.x264_r/src/x264_src/x264.c
                      ../525.x264_r/src/x264_src/encoder/macroblock.c
                      ../525.x264_r/src/x264_src/common/predict.c
                      ../525.x264_r/src/x264_src/common/deblock.c
                      ../525.x264_r/src/x264_src/encoder/cavlc.c
                      ../525.x264_r/src/x264_src/common/dct.c
                      ../525.x264_r/src/x264_src/common/macroblock.c
                      ../525.x264_r/src/x264_src/encoder/set.c
                      ../525.x264_r/src/x264_src/common/mc.c
                      ../525.x264_r/src/x264_src/encoder/ratecontrol.c
                      ../525.x264_r/src/x264_src/encoder/me.c
                      ../525.x264_r/src/x264_src/common/pixel.c
                      ../525.x264_r/src/x264_src/encoder/encoder.c
                      ../525.x264_r/src/x264_src/encoder/analyse.c)

set(625_X264_INCLUDE_DIR ../525.x264_r/src/x264_src/inc ../525.x264_r/src/x264_src
                         ../525.x264_r/src/x264_src/extras ../525.x264_r/src/x264_src/common)

add_library(x264_s SHARED ${SRC_FILE_625_X264})
target_compile_definitions(x264_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_OPENMP
    -DSPEC_AUTO_BYTEORDER=0x12345678
    -DSPEC_LP64)
target_include_directories(x264_s PUBLIC ${625_X264_INCLUDE_DIR})
target_compile_options(x264_s PRIVATE -fcommon -fopenmp)
target_link_libraries(x264_s PRIVATE libomp.so)

set_source_files_properties(${SRC_FILE_625_X264} PROPERTIES LANGUAGE C)

add_library(imagevalidate_625 SHARED ../525.x264_r/src/image_validator/ImageValidator.c)
