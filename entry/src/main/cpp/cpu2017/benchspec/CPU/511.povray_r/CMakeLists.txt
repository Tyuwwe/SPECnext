message(STATUS "Generating build files for 511.povray_r...")

set(SRC_FILE_511_POVRAY_CXX src/atmosph.cpp
                            src/bbox.cpp
                            src/bcyl.cpp
                            src/benchmark.cpp
                            src/bezier.cpp
                            src/blob.cpp
                            src/boxes.cpp
                            src/bsphere.cpp
                            src/camera.cpp
                            src/chi2.cpp
                            src/colour.cpp
                            src/colutils.cpp
                            src/cones.cpp
                            src/csg.cpp
                            src/discs.cpp
                            src/express.cpp
                            src/fncode.cpp
                            src/fnintern.cpp
                            src/fnpovfpu.cpp
                            src/fnsyntax.cpp
                            src/fpmetric.cpp
                            src/fractal.cpp
                            src/function.cpp
                            src/hcmplx.cpp
                            src/hfield.cpp
                            src/histogra.cpp
                            src/iff.cpp
                            src/image.cpp
                            src/interior.cpp
                            src/isosurf.cpp
                            src/lathe.cpp
                            src/lbuffer.cpp
                            src/lightgrp.cpp
                            src/lighting.cpp
                            src/mathutil.cpp
                            src/matrices.cpp
                            src/media.cpp
                            src/mesh.cpp
                            src/normal.cpp
                            src/objects.cpp
                            src/octree.cpp
                            src/optout.cpp
                            src/parse.cpp
                            src/parsestr.cpp
                            src/parstxtr.cpp
                            src/pattern.cpp
                            src/pgm.cpp
                            src/photons.cpp
                            src/pigment.cpp
                            src/planes.cpp
                            src/point.cpp
                            src/poly.cpp
                            src/polygon.cpp
                            src/polysolv.cpp
                            src/povmsend.cpp
                            src/povmsrec.cpp
                            src/povray.cpp
                            src/pov_mem.cpp
                            src/pov_util.cpp
                            src/ppm.cpp
                            src/prism.cpp
                            src/quadrics.cpp
                            src/quatern.cpp
                            src/radiosit.cpp
                            src/rad_data.cpp
                            src/ray.cpp
                            src/rendctrl.cpp
                            src/render.cpp
                            src/renderio.cpp
                            src/reswords.cpp
                            src/sor.cpp
                            src/spheres.cpp
                            src/sphsweep.cpp
                            src/splines.cpp
                            src/statspov.cpp
                            src/super.cpp
                            src/targa.cpp
                            src/texture.cpp
                            src/tokenize.cpp
                            src/torus.cpp
                            src/triangle.cpp
                            src/truetype.cpp
                            src/txttest.cpp
                            src/userdisp.cpp
                            src/userio.cpp
                            src/vbuffer.cpp
                            src/vlbuffer.cpp
                            src/warps.cpp
                            src/base/fileinputoutput.cpp
                            src/base/povms.cpp
                            src/base/povmscpp.cpp
                            src/base/processoptions.cpp
                            src/base/stringutilities.cpp
                            src/base/textstream.cpp
                            src/base/textstreambuffer.cpp
                            src/frontend/defaultplatformbase.cpp
                            src/frontend/defaultrenderfrontend.cpp
                            src/frontend/messageoutput.cpp
                            src/frontend/processrenderoptions.cpp
                            src/frontend/renderfrontend.cpp)

set(SRC_FILE_511_POVRAY_C src/spec_qsort/spec_qsort.c)
file(GLOB_RECURSE HEADER_FILE_511 src/*.h)

set(511_POVRAY_INCLUDE_DIR src src/frontend src/base src/spec_qsort)

add_library(povray_r SHARED ${HEADER_FILE_511_POVRAY} ${SRC_FILE_511_POVRAY_CXX} ${SRC_FILE_511_POVRAY_C})
target_compile_definitions(povray_r PRIVATE
    -DSPEC
    -DNDEBUG
    -DSPEC_AUTO_SUPPRESS_OPENMP
    -DSPEC_LP64)
target_include_directories(povray_r PUBLIC ${511_POVRAY_INCLUDE_DIR})
set_source_files_properties(${SRC_FILE_511_POVRAY_CXX} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${SRC_FILE_511_POVRAY_C} PROPERTIES LANGUAGE C)
set_source_files_properties(${HEADER_FILE_511} PROPERTIES LANGUAGE CXX)

add_library(imagevalidate_511 SHARED src/image_validator/ImageValidator.c)
