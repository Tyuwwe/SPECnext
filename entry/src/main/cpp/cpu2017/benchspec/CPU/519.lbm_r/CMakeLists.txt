message(STATUS "Generating build files for 519.lbm_r...")

file(GLOB_RECURSE SRC_FILE_519 src/*.c)
file(GLOB_RECURSE HEADER_FILE_519 src/*.h)


#set(519_INCLUDE_DIR src src/spec_mem_io src/sha-2 src/common src/liblzma/api src/liblzma/lzma src/liblzma/common src/liblzma/check src/liblzma/simple src/liblzma/delta src/liblzma/lz src/liblzma/rangecoder)

add_library(lbm_r SHARED ${HEADER_FILE_519} ${SRC_FILE_519})
target_compile_definitions(lbm_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64)
#target_include_directories(lbm_r PUBLIC ${519_INCLUDE_DIR} ${519_SYS_INCLUDE_DIR})
target_compile_options(lbm_r PRIVATE -w)
