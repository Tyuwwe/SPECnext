message(STATUS "Generating build files for 623.xalancbmk_s...")

file(GLOB_RECURSE SRC_FILE_623 ../523.xalancbmk_r/src/*.c ../523.xalancbmk_r/src/*.cc ../523.xalancbmk_r/src/*.cpp)
file(GLOB_RECURSE HEADER_FILE_623 ../523.xalancbmk_r/src/*.h ../523.xalancbmk_r/src/*.hpp)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_623 EXCLUDE REGEX "DOMDeepNodeListPool.c")
list(FILTER SRC_FILE_623 EXCLUDE REGEX "ValueStackOf.c")
list(FILTER SRC_FILE_623 EXCLUDE REGEX "TransENameMap.c")
list(FILTER SRC_FILE_623 EXCLUDE REGEX "Janitor.c")
list(FILTER SRC_FILE_623 EXCLUDE REGEX "RefStackOf.c")
list(FILTER SRC_FILE_623 EXCLUDE REGEX "xercesc/util")
list(FILTER SRC_FILE_623 EXCLUDE REGEX "XSNamedMap.c")

set(623_INCLUDE_DIR
        ../523.xalancbmk_r/src
        ../523.xalancbmk_r/src/xercesc
        ../523.xalancbmk_r/src/xercesc/dom
        ../523.xalancbmk_r/src/xercesc/dom/impl
        ../523.xalancbmk_r/src/xercesc/sax
        ../523.xalancbmk_r/src/xercesc/util/MsgLoaders/InMemory
        ../523.xalancbmk_r/src/xercesc/util/Transcoders/Iconv
        ../523.xalancbmk_r/src/xalanc/include)

add_library(xalancbmk_s SHARED
    ${SRC_FILE_623}
)
target_compile_definitions(xalancbmk_s PRIVATE
    -DSPEC
    -DNDEBUG

    -DAPP_NO_THREADS
    -DXALAN_INMEM_MSG_LOADER
    -DPROJ_XMLPARSER
    -DPROJ_XMLUTIL
    -DPROJ_PARSERS
    -DPROJ_SAX4C
    -DPROJ_SAX2
    -DPROJ_DOM
    -DPROJ_VALIDATORS
    -DXML_USE_INMEM_MESSAGELOADER

    -DSPEC_LINUX

    -DSPEC_OPENMP
    -DSPEC_LP64
)

target_include_directories(xalancbmk_s PUBLIC ${623_INCLUDE_DIR} ${623_SYS_INCLUDE_DIR})
target_compile_options(xalancbmk_s PRIVATE -w -fopenmp)
target_link_libraries(xalancbmk_s PRIVATE libomp.so)

set_source_files_properties(${HEADER_FILE_623} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_623} PROPERTIES LANGUAGE CXX)
