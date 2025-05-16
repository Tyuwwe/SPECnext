cmake_minimum_required(VERSION 3.5.0)
project(speccpu2017)

#enable_language(Fortran)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 11)

message(STATUS "Configuring SPEC CPU 2017... ")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Ofast")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Ofast")
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Ofast")

add_compile_options(-Ofast)

message(STATUS "C flags = ${CMAKE_C_FLAGS}")
message(STATUS "C++ flags = ${CMAKE_CXX_FLAGS}")
message(STATUS "Fortran flags = ${CMAKE_Fortran_FLAGS}")

# INTrate
add_subdirectory(benchspec/CPU/500.perlbench_r)
add_subdirectory(benchspec/CPU/502.gcc_r)
add_subdirectory(benchspec/CPU/505.mcf_r)
add_subdirectory(benchspec/CPU/520.omnetpp_r)
add_subdirectory(benchspec/CPU/523.xalancbmk_r)
add_subdirectory(benchspec/CPU/525.x264_r)
add_subdirectory(benchspec/CPU/531.deepsjeng_r)
add_subdirectory(benchspec/CPU/541.leela_r)
#add_subdirectory(benchspec/CPU/548.exchange2_r)
add_subdirectory(benchspec/CPU/557.xz_r)

# FPrate
add_subdirectory(benchspec/CPU/508.namd_r)
add_subdirectory(benchspec/CPU/510.parest_r)
add_subdirectory(benchspec/CPU/511.povray_r)
add_subdirectory(benchspec/CPU/519.lbm_r)
add_subdirectory(benchspec/CPU/526.blender_r)
add_subdirectory(benchspec/CPU/538.imagick_r)
add_subdirectory(benchspec/CPU/544.nab_r)

# INTspeed
add_subdirectory(benchspec/CPU/600.perlbench_s)
add_subdirectory(benchspec/CPU/605.mcf_s)
add_subdirectory(benchspec/CPU/620.omnetpp_s)

#FPspeed
add_subdirectory(benchspec/CPU/619.lbm_s)
