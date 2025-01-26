message(STATUS "Generating build files for 531.deepsjeng_r...")

file(GLOB_RECURSE SRC_FILE_531 src/*.cpp)
file(GLOB_RECURSE HEADER_FILE_531 src/*.h)

add_library(deepsjeng_r SHARED
    ${SRC_FILE_531}
#    ${HEADER_FILE_531}
)
target_compile_definitions(deepsjeng_r PRIVATE
    -DSPEC
    -DNDEBUG

    -DSMALL_MEMORY

    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64
)

target_compile_options(deepsjeng_r PRIVATE -w)
set_source_files_properties(${HEADER_FILE_531} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_531} PROPERTIES LANGUAGE CXX)
target_link_libraries(deepsjeng_r PRIVATE wrap)
target_link_options(deepsjeng_r PRIVATE -Wl,--wrap=malloc
                                         -Wl,--wrap=calloc
                                         -Wl,--wrap=realloc
                                         -Wl,--wrap=free)
