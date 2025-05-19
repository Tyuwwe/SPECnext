message(STATUS "Generating build files for 631.deepsjeng_s...")

file(GLOB_RECURSE SRC_FILE_631 ../531.deepsjeng_r/src/*.cpp)
file(GLOB_RECURSE HEADER_FILE_631 ../531.deepsjeng_r/src/*.h)

add_library(deepsjeng_s SHARED
    ${SRC_FILE_631}
#    ${HEADER_FILE_631}
)
target_compile_definitions(deepsjeng_s PRIVATE
     -DSPEC -DNDEBUG -DBIG_MEMORY -DSPEC_OPENMP -DSPEC_LP64
)

target_compile_options(deepsjeng_s PRIVATE -w -fopenmp)
target_link_libraries(deepsjeng_s PRIVATE libomp.so)

set_source_files_properties(${HEADER_FILE_631} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_631} PROPERTIES LANGUAGE CXX)
target_link_libraries(deepsjeng_s PRIVATE wrap)
target_link_options(deepsjeng_s PRIVATE -Wl,--wrap=malloc
                                         -Wl,--wrap=calloc
                                         -Wl,--wrap=realloc
                                         -Wl,--wrap=free)
