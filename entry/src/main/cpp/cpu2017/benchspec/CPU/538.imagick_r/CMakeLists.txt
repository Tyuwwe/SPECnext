message(STATUS "Generating build files for 538.imagick_r...")

file(GLOB_RECURSE SRC_FILE_538_IMAGICK src/*.c)
file(GLOB_RECURSE HEADER_FILE_538 src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_538_IMAGICK EXCLUDE REGEX "ImageValidator.c")

set(538_IMAGICK_INCLUDE_DIR src)

add_library(imagick_r SHARED ${HEADER_FILE_538_IMAGICK} ${SRC_FILE_538_IMAGICK})
target_compile_definitions(imagick_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64)
target_include_directories(imagick_r PUBLIC ${538_IMAGICK_INCLUDE_DIR})
target_compile_options(imagick_r PRIVATE -fcommon)


add_library(imagevalidate_538 SHARED src/image_validator/ImageValidator.c)
