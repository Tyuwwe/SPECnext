message(STATUS "Generating build files for 510.parest_r...")

file(GLOB_RECURSE SRC_FILE_510 src/*.c src/*.cc src/*.cpp)
file(GLOB_RECURSE HEADER_FILE_510 src/*.h src/*.hpp)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_510 EXCLUDE REGEX "tss_null.cpp")
list(FILTER SRC_FILE_510 EXCLUDE REGEX "win32")
list(FILTER HEADER_FILE_510 EXCLUDE REGEX "win32")
list(FILTER SRC_FILE_510 EXCLUDE REGEX "pthread")
list(FILTER HEADER_FILE_510 EXCLUDE REGEX "win32")

set(510_INCLUDE_DIR src src/include)

add_library(parest_r SHARED
    ${SRC_FILE_510}
#    ${HEADER_FILE_510}
)
target_compile_definitions(parest_r PRIVATE
    -DSPEC
    -DNDEBUG

    -DBOOST_DISABLE_THREADS

    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64
)
target_compile_options(parest_r PRIVATE
    -U__linux__
)
target_include_directories(parest_r PUBLIC ${510_INCLUDE_DIR} ${510_SYS_INCLUDE_DIR})
target_compile_options(parest_r PRIVATE -w)
set_source_files_properties(${HEADER_FILE_510} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_510} PROPERTIES LANGUAGE CXX)
