message(STATUS "Generating build files for 544.nab_r...")

file(GLOB_RECURSE SRC_FILE_544 src/*.c)
file(GLOB_RECURSE HEADER_FILE_544 src/*.h)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_544 EXCLUDE REGEX "gbsa.c")
list(FILTER SRC_FILE_544 EXCLUDE REGEX "eff.c")
list(FILTER SRC_FILE_544 EXCLUDE REGEX "intersect.c")

set(544_INCLUDE_DIR src/specrand src/regex-alpha)

add_library(nab_r SHARED ${HEADER_FILE_544} ${SRC_FILE_544})
target_compile_definitions(nab_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DNOPERFLIB
    -DNOREDUCE
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64)
target_include_directories(nab_r PUBLIC ${544_INCLUDE_DIR} ${544_SYS_INCLUDE_DIR})
target_compile_options(nab_r PRIVATE -w)
