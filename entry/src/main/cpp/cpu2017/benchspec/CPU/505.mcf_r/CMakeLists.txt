message(STATUS "Generating build files for 505.mcf_r...")

file(GLOB_RECURSE SRC_FILE_505 src/*.c)
list(APPEND SRC_FILE_505 src/spec_qsort/spec_qsort.c)
file(GLOB_RECURSE HEADER_FILE_505 src/*.h)
list(APPEND HEADER_FILE_505 src/spec_qsort/spec_qsort.h)

set(505_INCLUDE_DIR src/spec_qsort)

add_library(mcf_r SHARED ${SRC_FILE_505} ${HEADER_FILE_505})
target_include_directories(mcf_r PRIVATE ${505_INCLUDE_DIR})
target_compile_definitions(mcf_r PUBLIC PRId64="%lld")
target_compile_definitions(mcf_r PUBLIC SPEC)
target_link_libraries(mcf_r PRIVATE wrap)

