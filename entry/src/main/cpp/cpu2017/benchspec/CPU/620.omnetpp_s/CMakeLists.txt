message(STATUS "Generating build files for 620.omnetpp_s...")

file(GLOB_RECURSE SRC_FILE_620 ../520.omnetpp_r/src/*.c ../520.omnetpp_r/src/*.cc)
file(GLOB_RECURSE HEADER_FILE_620 ../520.omnetpp_r/src/*.h)

# Exclude these files since they will be included by preprocessor directives
#list(FILTER SRC_FILE_620 EXCLUDE REGEX "gbsa.c")

set(620_INCLUDE_DIR ../520.omnetpp_r/src/simulator/platdep ../520.omnetpp_r/src/simulator ../520.omnetpp_r/src/model)

add_library(omnetpp_s SHARED ${HEADER_FILE_620} ${SRC_FILE_620})
target_compile_definitions(omnetpp_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DWITH_NETBUILDER
    -DSPEC_OPENMP
    -DSPEC_LP64
    -DNO_GCVT
)
target_include_directories(omnetpp_s PUBLIC ${620_INCLUDE_DIR} ${620_SYS_INCLUDE_DIR})
target_compile_options(omnetpp_s PRIVATE -w -fopenmp)
target_link_libraries(omnetpp_s PRIVATE libomp.so)
