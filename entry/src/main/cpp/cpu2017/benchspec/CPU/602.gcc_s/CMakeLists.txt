message(STATUS "Generating build files for 602.gcc_s...")

file(GLOB_RECURSE SRC_FILE_602 ../502.gcc_r/src/*.c)
file(GLOB_RECURSE HEADER_FILE_602 ../502.gcc_r/src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_602 EXCLUDE REGEX "gcov-io.c")
list(FILTER HEADER_FILE_602 EXCLUDE REGEX "gcov-io.h")

set(602_INCLUDE_DIR ../502.gcc_r/src ../502.gcc_r/src/spec_qsort ../502.gcc_r/src/include)
set(602_SYS_INCLUDE_DIR ../502.gcc_r/src/config ../502.gcc_r/src/config/i386)

add_library(gcc_s SHARED ${HEADER_FILE_602} ${SRC_FILE_602})
target_compile_definitions(gcc_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_602
    -DSPEC_OPENMP
    -DIN_GCC
    -DHAVE_CONFIG_H
    -DSPEC_LP64)
target_include_directories(gcc_s PUBLIC ${602_INCLUDE_DIR} ${602_SYS_INCLUDE_DIR})
target_compile_options(gcc_s PRIVATE -w)
target_link_libraries(gcc_s PRIVATE wrap)

target_link_options(gcc_s PRIVATE
    -Wl,--wrap=malloc
    -Wl,--wrap=calloc
    -Wl,--wrap=realloc
    -Wl,--wrap=free)

set_source_files_properties(${SRC_FILE_602} PROPERTIES LANGUAGE C)
