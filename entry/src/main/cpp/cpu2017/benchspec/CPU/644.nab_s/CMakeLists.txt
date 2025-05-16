message(STATUS "Generating build files for 644.nab_s...")

file(GLOB_RECURSE SRC_FILE_644 ../544.nab_r/src/*.c)
file(GLOB_RECURSE HEADER_FILE_644 ../544.nab_r/src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_644 EXCLUDE REGEX "gbsa.c")
list(FILTER SRC_FILE_644 EXCLUDE REGEX "eff.c")
list(FILTER SRC_FILE_644 EXCLUDE REGEX "intersect.c")

set(644_INCLUDE_DIR ../544.nab_r/src/specrand ../544.nab_r/src/regex-alpha)

add_library(nab_s SHARED ${HEADER_FILE_644} ${SRC_FILE_644})
target_compile_definitions(nab_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DNOPERFLIB
    -DNOREDUCE
    -DSPEC_OPENMP
    -DSPEC_LP64)
target_include_directories(nab_s PUBLIC ${644_INCLUDE_DIR} ${644_SYS_INCLUDE_DIR})
target_compile_options(nab_s PRIVATE -w -fopenmp)
target_link_libraries(nab_s PRIVATE libomp.so)
