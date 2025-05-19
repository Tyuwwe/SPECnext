message(STATUS "Generating build files for 605.mcf_s...")

file(GLOB_RECURSE SRC_FILE_605 ../505.mcf_r/src/*.c)
list(APPEND SRC_FILE_605 ../505.mcf_r/src/spec_qsort/spec_qsort.c)
file(GLOB_RECURSE HEADER_FILE_605 ../505.mcf_r/src/*.h)
list(APPEND HEADER_FILE_605 ../505.mcf_r/src/spec_qsort/spec_qsort.h)

set(605_INCLUDE_DIR ../505.mcf_r/src/spec_qsort)

add_library(mcf_s SHARED ${SRC_FILE_605} ${HEADER_FILE_605})

target_compile_definitions(mcf_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_OPENMP
    -DSPEC_LP64
)

target_compile_options(mcf_s PRIVATE
    -fno-strict-aliasing -fno-unsafe-math-optimizations -fno-finite-math-only -fgnu89-inline -fcommon -fopenmp)

target_include_directories(mcf_s PRIVATE ${605_INCLUDE_DIR})
target_compile_definitions(mcf_s PUBLIC PRId64="%lld")
target_link_libraries(mcf_s PRIVATE wrap)
target_link_libraries(mcf_s PRIVATE libomp.so)
