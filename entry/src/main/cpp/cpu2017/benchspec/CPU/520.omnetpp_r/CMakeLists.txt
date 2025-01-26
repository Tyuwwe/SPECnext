message(STATUS "Generating build files for 520.omnetpp_r...")

file(GLOB_RECURSE SRC_FILE_520 src/*.c src/*.cc)
file(GLOB_RECURSE HEADER_FILE_520 src/*.h)

# Exclude these files since they will be included by preprocessor directives
#list(FILTER SRC_FILE_520 EXCLUDE REGEX "gbsa.c")

set(520_INCLUDE_DIR src/simulator/platdep src/simulator src/model)

add_library(omnetpp_r SHARED ${HEADER_FILE_520} ${SRC_FILE_520})
target_compile_definitions(omnetpp_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DWITH_NETBUILDER
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64
    -DNO_GCVT
)
target_include_directories(omnetpp_r PUBLIC ${520_INCLUDE_DIR} ${520_SYS_INCLUDE_DIR})
target_compile_options(omnetpp_r PRIVATE -w)
