message(STATUS "Generating build files for 523.xalancbmk_r...")

file(GLOB_RECURSE SRC_FILE_523 src/*.c src/*.cc src/*.cpp)
file(GLOB_RECURSE HEADER_FILE_523 src/*.h src/*.hpp)

# Exclude these files since they will be included by preprocessor directives
list(FILTER SRC_FILE_523 EXCLUDE REGEX "DOMDeepNodeListPool.c")
list(FILTER SRC_FILE_523 EXCLUDE REGEX "ValueStackOf.c")
list(FILTER SRC_FILE_523 EXCLUDE REGEX "TransENameMap.c")
list(FILTER SRC_FILE_523 EXCLUDE REGEX "Janitor.c")
list(FILTER SRC_FILE_523 EXCLUDE REGEX "RefStackOf.c")
list(FILTER SRC_FILE_523 EXCLUDE REGEX "xercesc/util")
list(FILTER SRC_FILE_523 EXCLUDE REGEX "XSNamedMap.c")

set(523_INCLUDE_DIR src src/xercesc src/xercesc/dom src/xercesc/dom/impl src/xercesc/sax src/xercesc/util/MsgLoaders/InMemory src/xercesc/util/Transcoders/Iconv src/xalanc/include)

add_library(xalancbmk_r SHARED
    ${SRC_FILE_523}
#    ${HEADER_FILE_523}
)
target_compile_definitions(xalancbmk_r PRIVATE
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

    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64
)
target_include_directories(xalancbmk_r PUBLIC ${523_INCLUDE_DIR} ${523_SYS_INCLUDE_DIR})
target_compile_options(xalancbmk_r PRIVATE -w)
set_source_files_properties(${HEADER_FILE_523} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_523} PROPERTIES LANGUAGE CXX)
