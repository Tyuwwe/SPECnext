message(STATUS "Generating build files for 641.leela_s...")

file(GLOB_RECURSE SRC_FILE_641 ../541.leela_r/src/*.c ../541.leela_r/src/*.cc ../541.leela_r/src/*.cpp)
file(GLOB_RECURSE HEADER_FILE_641 ../541.leela_r/src/*.h ../541.leela_r/src/*.hpp)

# Exclude these files since they will be included by preprocessor directives
#list(FILTER SRC_FILE_641 EXCLUDE REGEX "DOMDeepNodeListPool.c")

set(641_INCLUDE_DIR ../541.leela_r/src)

add_library(leela_s SHARED
    ${SRC_FILE_641}
#    ${HEADER_FILE_641}
)
target_compile_definitions(leela_s PRIVATE
    -DSPEC -DNDEBUG -DSPEC_OPENMP -DSPEC_LP64
)
target_include_directories(leela_s PUBLIC ${641_INCLUDE_DIR} ${641_SYS_INCLUDE_DIR})
target_compile_options(leela_s PRIVATE -w -fopenmp)
target_link_libraries(leela_s PRIVATE libomp.so)
set_source_files_properties(${HEADER_FILE_641} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_641} PROPERTIES LANGUAGE CXX)
