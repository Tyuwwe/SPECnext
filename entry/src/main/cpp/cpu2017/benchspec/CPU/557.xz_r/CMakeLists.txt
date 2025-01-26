message(STATUS "Generating build files for 557.xz_r...")

file(GLOB_RECURSE SRC_FILE_557 src/*.c)
file(GLOB_RECURSE HEADER_FILE_557 src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_557 EXCLUDE REGEX "crc32_small.c")
list(FILTER SRC_FILE_557 EXCLUDE REGEX "crc64_small.c")
list(FILTER SRC_FILE_557 EXCLUDE REGEX "fastpos_tablegen.c")
list(FILTER SRC_FILE_557 EXCLUDE REGEX "price_tablegen.c")

set(557_INCLUDE_DIR src src/spec_mem_io src/sha-2 src/common src/liblzma/api src/liblzma/lzma src/liblzma/common src/liblzma/check src/liblzma/simple src/liblzma/delta src/liblzma/lz src/liblzma/rangecoder)

add_library(xz_r SHARED ${HEADER_FILE_557} ${SRC_FILE_557})
target_compile_definitions(xz_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_AUTO_BYTEORDER=0x12345678
    -DHAVE_CONFIG_H=1
    -DSPEC_MEM_IO
    -DSPEC_XZ
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64)
target_include_directories(xz_r PUBLIC ${557_INCLUDE_DIR} ${557_SYS_INCLUDE_DIR})
target_compile_options(xz_r PRIVATE -w)
target_link_libraries(xz_r PRIVATE wrap)
target_link_options(xz_r PRIVATE
    -Wl,--wrap=malloc
    -Wl,--wrap=calloc
    -Wl,--wrap=realloc
    -Wl,--wrap=free)
