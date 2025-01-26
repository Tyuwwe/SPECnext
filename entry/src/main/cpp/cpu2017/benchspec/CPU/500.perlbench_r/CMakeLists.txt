message(STATUS "Generating build files for 500.perlbench_r...")

file(GLOB_RECURSE SRC_FILE_500 src/*.c)
file(GLOB_RECURSE HEADER_FILE_500 src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_500 EXCLUDE REGEX "dquote.c")
list(FILTER SRC_FILE_500 EXCLUDE REGEX "sdf.c")
list(FILTER SRC_FILE_500 EXCLUDE REGEX "parser-util.c")
list(FILTER SRC_FILE_500 EXCLUDE REGEX "hparser.c")
list(FILTER SRC_FILE_500 EXCLUDE REGEX "win32")
list(FILTER SRC_FILE_500 EXCLUDE REGEX "time64.c")
list(FILTER SRC_FILE_500 EXCLUDE REGEX "time64.h")
list(FILTER SRC_FILE_500 EXCLUDE REGEX "vutil.c")
list(FILTER SRC_FILE_500 EXCLUDE REGEX "sha.c")

set(500_INCLUDE_DIR src src/dist/IO src/cpan/Time-HiRes src/cpan/HTML-Parser src/cpan/Digest-SHA/src src/ext/re src/specrand)

add_library(perlbench_r SHARED ${HEADER_FILE_500} ${SRC_FILE_500})
target_compile_definitions(perlbench_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DPERL_CORE
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DDOUBLE_SLASHES_SPECIAL=0
    -D_LARGE_FILES -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
    -DSPEC_NO_USE_STDIO_BASE
    -DSPEC_MANUAL_CONFIG
    -DSPEC_LINUX
    -DI_FCNTL
    -DSPEC_NO_USE_STDIO_PTR
    -DSPEC_LP64)
target_include_directories(perlbench_r PUBLIC ${500_INCLUDE_DIR} ${500_SYS_INCLUDE_DIR})
target_compile_options(perlbench_r PRIVATE -w)
target_link_libraries(perlbench_r PRIVATE wrap)
target_link_options(perlbench_r PRIVATE -Wl,--wrap=malloc
                                         -Wl,--wrap=calloc
                                         -Wl,--wrap=realloc
                                         -Wl,--wrap=free)
