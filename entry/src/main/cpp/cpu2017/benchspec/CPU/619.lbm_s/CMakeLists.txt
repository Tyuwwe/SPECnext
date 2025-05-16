message(STATUS "Generating build files for 619.lbm_s...")

file(GLOB_RECURSE SRC_FILE_619 ../519.lbm_r/src/*.c)
file(GLOB_RECURSE HEADER_FILE_619 ../519.lbm_r/src/*.h)

add_library(lbm_s SHARED ${HEADER_FILE_619} ${SRC_FILE_619})
target_compile_definitions(lbm_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DLARGE_WORKLOAD
    -DSPEC_OPENMP
    -DSPEC_LP64)
#target_include_directories(lbm_s PUBLIC ${619_INCLUDE_DIR} ${619_SYS_INCLUDE_DIR})
target_link_libraries(lbm_s PRIVATE libomp.so)
target_compile_options(lbm_s PRIVATE -w -fopenmp)
