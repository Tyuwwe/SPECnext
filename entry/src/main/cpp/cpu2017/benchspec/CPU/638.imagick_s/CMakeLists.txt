message(STATUS "Generating build files for 638.imagick_s...")

file(GLOB_RECURSE SRC_FILE_638_IMAGICK ../538.imagick_r/src/*.c)
file(GLOB_RECURSE HEADER_FILE_638 ../538.imagick_r/src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_638_IMAGICK EXCLUDE REGEX "ImageValidator.c")

set(638_IMAGICK_INCLUDE_DIR ../538.imagick_r/src)

add_library(imagick_s SHARED ${HEADER_FILE_638_IMAGICK} ${SRC_FILE_638_IMAGICK})
target_compile_definitions(imagick_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_OPENMP
    -DSPEC_LP64)
target_include_directories(imagick_s PUBLIC ${638_IMAGICK_INCLUDE_DIR})
target_compile_options(imagick_s PRIVATE -fcommon -fopenmp)
target_link_libraries(imagick_s PRIVATE libomp.so)

add_library(imagevalidate_638 SHARED ../538.imagick_r/src/image_validator/ImageValidator.c)
