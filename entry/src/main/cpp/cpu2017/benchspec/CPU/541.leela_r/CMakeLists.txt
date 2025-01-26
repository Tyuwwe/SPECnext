message(STATUS "Generating build files for 541.leela_r...")

file(GLOB_RECURSE SRC_FILE_541 src/*.c src/*.cc src/*.cpp)
file(GLOB_RECURSE HEADER_FILE_541 src/*.h src/*.hpp)

# Exclude these files since they will be included by preprocessor directives
#list(FILTER SRC_FILE_541 EXCLUDE REGEX "DOMDeepNodeListPool.c")

set(541_INCLUDE_DIR src)

add_library(leela_r SHARED
    ${SRC_FILE_541}
#    ${HEADER_FILE_541}
)
target_compile_definitions(leela_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64
)
target_include_directories(leela_r PUBLIC ${541_INCLUDE_DIR} ${541_SYS_INCLUDE_DIR})
target_compile_options(leela_r PRIVATE -w)
set_source_files_properties(${HEADER_FILE_541} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_541} PROPERTIES LANGUAGE CXX)
