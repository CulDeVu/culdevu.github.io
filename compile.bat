@echo off

rem 4710, 4711, and 4267 are double -> float and int -> int conversion warnings
rem 4521 is there to silence some dumb c++ shit
rem 4100 unreferenced parameter
rem 420x, 4221 are "nonstandard" extensions, aka things that were introduced in c99 and c11
rem add /Bt /d2cgsummary for compiler timings
set OPTIONS=-nologo -MT -W4 -wd4710 -wd4711 -wd4267 -wd4996 -wd4244 -wd4521 -wd4100 -wd4201 -wd4204 -wd4221 -Oi -EHs-c- -FC
set JNI_INCLUDES=/I "C:\Program Files\Java\jdk1.8.0_201\include" /I "C:\Program Files\Java\jdk1.8.0_201\include\win32"

set DEBUG_OPTIONS=-DDJDB_MEMORY_DEBUG -Od
set OPTIM_OPTIONS=-Od

set BUILD_FAILED=1

mkdir build
pushd build

rem cl %OPTIONS% ../codegen.c

cl %OPTIONS% -ZI -Od ../generator.c %JNI_INCLUDES%

popd
