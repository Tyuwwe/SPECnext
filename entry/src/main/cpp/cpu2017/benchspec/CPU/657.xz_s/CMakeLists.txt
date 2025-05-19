message(STATUS "Generating build files for 657.xz_s...")

file(GLOB_RECURSE SRC_FILE_657 ../557.xz_r/src/*.c)
file(GLOB_RECURSE HEADER_FILE_657 ../557.xz_r/src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_657 EXCLUDE REGEX "crc32_small.c")
list(FILTER SRC_FILE_657 EXCLUDE REGEX "crc64_small.c")
list(FILTER SRC_FILE_657 EXCLUDE REGEX "fastpos_tablegen.c")
list(FILTER SRC_FILE_657 EXCLUDE REGEX "price_tablegen.c")

set(657_INCLUDE_DIR ../557.xz_r/src ../557.xz_r/src/spec_mem_io ../557.xz_r/src/sha-2 ../557.xz_r/src/common ../557.xz_r/src/liblzma/api ../557.xz_r/src/liblzma/lzma ../557.xz_r/src/liblzma/common ../557.xz_r/src/liblzma/check ../557.xz_r/src/liblzma/simple ../557.xz_r/src/liblzma/delta ../557.xz_r/src/liblzma/lz ../557.xz_r/src/liblzma/rangecoder)

add_library(xz_s SHARED ${HEADER_FILE_657} ${SRC_FILE_657})
target_compile_definitions(xz_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_AUTO_BYTEORDER=0x12345678
    -DHAVE_CONFIG_H=1
    -DSPEC_MEM_IO
    -DSPEC_XZ
    -DSPEC_OPENMP
    -DSPEC_LP64)
target_include_directories(xz_s PUBLIC ${657_INCLUDE_DIR} ${657_SYS_INCLUDE_DIR})
target_compile_options(xz_s PRIVATE -w -fopenmp)
target_link_libraries(xz_s PRIVATE libomp.so)
target_link_libraries(xz_s PRIVATE wrap)
target_link_options(xz_s PRIVATE
    -Wl,--wrap=malloc
    -Wl,--wrap=calloc
    -Wl,--wrap=realloc
    -Wl,--wrap=free)
