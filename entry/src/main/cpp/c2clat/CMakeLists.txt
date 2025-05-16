project(c2clat)
cmake_minimum_required(VERSION 3.10)

add_library(c2clat SHARED c2clat.cpp)
target_compile_options(c2clat PRIVATE "-O3")
target_compile_definitions(c2clat PRIVATE "-DNDEBUG")
