message(STATUS "Generating build files for 502.gcc_r...")

file(GLOB_RECURSE SRC_FILE_502 src/*.c)
file(GLOB_RECURSE HEADER_FILE_502 src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_502 EXCLUDE REGEX "gcov-io.c")
list(FILTER HEADER_FILE_502 EXCLUDE REGEX "gcov-io.h")

set(502_INCLUDE_DIR src src/spec_qsort src/include)
set(502_SYS_INCLUDE_DIR src/config src/config/i386)

add_library(gcc_r SHARED ${HEADER_FILE_502} ${SRC_FILE_502})
target_compile_definitions(gcc_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_502
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DIN_GCC
    -DHAVE_CONFIG_H
    -DSPEC_LP64)
target_include_directories(gcc_r PUBLIC ${502_INCLUDE_DIR} ${502_SYS_INCLUDE_DIR})
target_compile_options(gcc_r PRIVATE -w)
target_link_libraries(gcc_r PRIVATE wrap)

target_link_options(gcc_r PRIVATE
    -Wl,--wrap=malloc
    -Wl,--wrap=calloc
    -Wl,--wrap=realloc
    -Wl,--wrap=free)

set_source_files_properties(${SRC_FILE_502} PROPERTIES LANGUAGE C)
