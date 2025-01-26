message(STATUS "Generating build files for 508.namd_r...")

file(GLOB_RECURSE SRC_FILE_508 src/*.c src/*.cc src/*.cpp)
file(GLOB_RECURSE HEADER_FILE_508 src/*.h src/*.hpp)

add_library(namd_r SHARED
    ${SRC_FILE_508}
)
target_compile_definitions(namd_r PRIVATE
    -DSPEC
    -DNDEBUG

    -DNAMD_DISABLE_SSE

    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64
)
target_compile_options(namd_r PRIVATE -w)
set_source_files_properties(${HEADER_FILE_508} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_508} PROPERTIES LANGUAGE CXX)
