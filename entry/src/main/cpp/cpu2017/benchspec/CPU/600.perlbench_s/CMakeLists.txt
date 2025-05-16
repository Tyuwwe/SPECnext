message(STATUS "Generating build files for 600.perlbench_s...")

set(SRC_FILE_600 ../500.perlbench_r/src/av.c
                 ../500.perlbench_r/src/caretx.c
                 ../500.perlbench_r/src/deb.c
                 ../500.perlbench_r/src/doio.c
                 ../500.perlbench_r/src/doop.c
                 ../500.perlbench_r/src/dump.c
                 ../500.perlbench_r/src/globals.c
                 ../500.perlbench_r/src/gv.c
                 ../500.perlbench_r/src/hv.c
                 ../500.perlbench_r/src/keywords.c
                 ../500.perlbench_r/src/locale.c
                 ../500.perlbench_r/src/mg.c
                 ../500.perlbench_r/src/numeric.c
                 ../500.perlbench_r/src/op.c
                 ../500.perlbench_r/src/pad.c
                 ../500.perlbench_r/src/perl.c
                 ../500.perlbench_r/src/perlapi.c
                 ../500.perlbench_r/src/perlio.c
                 ../500.perlbench_r/src/perlmain.c
                 ../500.perlbench_r/src/perly.c
                 ../500.perlbench_r/src/pp.c
                 ../500.perlbench_r/src/pp_ctl.c
                 ../500.perlbench_r/src/pp_hot.c
                 ../500.perlbench_r/src/pp_pack.c
                 ../500.perlbench_r/src/pp_sort.c
                 ../500.perlbench_r/src/pp_sys.c
                 ../500.perlbench_r/src/regcomp.c
                 ../500.perlbench_r/src/regexec.c
                 ../500.perlbench_r/src/run.c
                 ../500.perlbench_r/src/scope.c
                 ../500.perlbench_r/src/sv.c
                 ../500.perlbench_r/src/taint.c
                 ../500.perlbench_r/src/toke.c
                 ../500.perlbench_r/src/universal.c
                 ../500.perlbench_r/src/utf8.c
                 ../500.perlbench_r/src/util.c
                 ../500.perlbench_r/src/reentr.c
                 ../500.perlbench_r/src/mro_core.c
                 ../500.perlbench_r/src/mathoms.c
                 ../500.perlbench_r/src/specrand/specrand.c
                 ../500.perlbench_r/src/dist/PathTools/Cwd.c
                 ../500.perlbench_r/src/dist/Data-Dumper/Dumper.c
                 ../500.perlbench_r/src/ext/Devel-Peek/Peek.c
                 ../500.perlbench_r/src/cpan/Digest-MD5/MD5.c
                 ../500.perlbench_r/src/cpan/Digest-SHA/SHA.c
                 ../500.perlbench_r/src/DynaLoader.c
                 ../500.perlbench_r/src/dist/IO/IO.c
                 ../500.perlbench_r/src/dist/IO/poll.c
                 ../500.perlbench_r/src/cpan/MIME-Base64/Base64.c
                 ../500.perlbench_r/src/Opcode.c
                 ../500.perlbench_r/src/dist/Storable/Storable.c
                 ../500.perlbench_r/src/ext/Sys-Hostname/Hostname.c
                 ../500.perlbench_r/src/cpan/Time-HiRes/HiRes.c
                 ../500.perlbench_r/src/ext/XS-Typemap/stdio.c
                 ../500.perlbench_r/src/ext/attributes/attributes.c
                 ../500.perlbench_r/src/cpan/HTML-Parser/Parser.c
                 ../500.perlbench_r/src/ext/mro/mro.c
                 ../500.perlbench_r/src/ext/re/re.c
                 ../500.perlbench_r/src/ext/re/re_comp.c
                 ../500.perlbench_r/src/ext/re/re_exec.c
                 ../500.perlbench_r/src/ext/arybase/arybase.c
                 ../500.perlbench_r/src/ext/PerlIO-scalar/scalar.c
                 ../500.perlbench_r/src/ext/PerlIO-via/via.c
                 ../500.perlbench_r/src/ext/File-Glob/bsd_glob.c
                 ../500.perlbench_r/src/ext/File-Glob/Glob.c
                 ../500.perlbench_r/src/ext/Hash-Util/Util.c
                 ../500.perlbench_r/src/ext/Hash-Util-FieldHash/FieldHash.c
                 ../500.perlbench_r/src/ext/Tie-Hash-NamedCapture/NamedCapture.c
                 ../500.perlbench_r/src/cpan/Scalar-List-Utils/ListUtil.c)

set(600_INCLUDE_DIR
    ../500.perlbench_r/src
    ../500.perlbench_r/src/dist/IO
    ../500.perlbench_r/src/cpan/Time-HiRes
    ../500.perlbench_r/src/cpan/HTML-Parser
    ../500.perlbench_r/src/cpan/Digest-SHA/src
    ../500.perlbench_r/src/ext/re
    ../500.perlbench_r/src/specrand)

add_library(perlbench_s SHARED ${SRC_FILE_600})

target_include_directories(perlbench_s PUBLIC ${600_INCLUDE_DIR} ${600_SYS_INCLUDE_DIR})

target_compile_definitions(perlbench_s PRIVATE
    -DSPEC
    -DNDEBUG
    -DPERL_CORE
    -DDOUBLE_SLASHES_SPECIAL=0
    -D_LARGE_FILES -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
    -DSPEC_NO_USE_STDIO_BASE
    -DSPEC_MANUAL_CONFIG
    -DSPEC_LINUX
    -DI_FCNTL
    -DSPEC_NO_USE_STDIO_PTR
    -DSPEC_LP64
    -DSPEC_OPENMP
)


target_compile_options(perlbench_s PRIVATE -w
    -fno-strict-aliasing -fno-unsafe-math-optimizations -fno-finite-math-only -fgnu89-inline -fcommon
    -fopenmp
    -fvectorize
    -Rpass-analysis=loop-vectorize -Rpass=loop-vectorize -Rpass-missed=loop-vectorize)


target_link_libraries(perlbench_s PRIVATE wrap)
target_link_options(perlbench_s PRIVATE -Wl,--wrap=malloc
                                         -Wl,--wrap=calloc
                                         -Wl,--wrap=realloc
                                         -Wl,--wrap=free)


#file(GLOB_RECURSE SRC_FILE_600 ../500.perlbench_r/src*.c)
#file(GLOB_RECURSE HEADER_FILE_600 ../500.perlbench_r/src*.h)
#
## Exclude these files since they will be included by preprocessor directives
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "dquote.c")
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "sdf.c")
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "parser-util.c")
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "hparser.c")
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "win32")
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "time64.c")
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "time64.h")
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "vutil.c")
#list(FILTER SRC_FILE_600 EXCLUDE REGEX "sha.c")
#
#set(600_INCLUDE_DIR src ../500.perlbench_r/srcdist/IO ../500.perlbench_r/srccpan/Time-HiRes ../500.perlbench_r/srccpan/HTML-Parser ../500.perlbench_r/srccpan/Digest-SHA/src ../500.perlbench_r/srcext/re ../500.perlbench_r/srcspecrand)
#
#add_library(perlbench_r SHARED ${HEADER_FILE_600} ${SRC_FILE_600})
#target_compile_definitions(perlbench_r PRIVATE
#    -DSPEC
#    -DNDEBUG
#    -DPERL_CORE
#    -DSPEC_AUTO_SUPPRESS_OPENMP
#    -DDOUBLE_SLASHES_SPECIAL=0
#    -D_LARGE_FILES -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
#    -DSPEC_NO_USE_STDIO_BASE
#    -DSPEC_MANUAL_CONFIG
#    -DSPEC_LINUX
#    -DI_FCNTL
#    -DSPEC_NO_USE_STDIO_PTR
#    -DSPEC_LP64)
#target_include_directories(perlbench_r PUBLIC ${600_INCLUDE_DIR} ${600_SYS_INCLUDE_DIR})
#target_compile_options(perlbench_r PRIVATE -w)
#target_link_libraries(perlbench_r PRIVATE wrap)
#target_link_options(perlbench_r PRIVATE -Wl,--wrap=malloc
#                                         -Wl,--wrap=calloc
#                                         -Wl,--wrap=realloc
#                                         -Wl,--wrap=free)
