##
## Author: Hank Anderson <hank@statease.com>
## Description: Ported from portion of OpenBLAS/Makefile.system
##              Sets Fortran related variables.

if (${F_COMPILER} STREQUAL "FLANG" AND NOT CMAKE_Fortran_COMPILER_ID STREQUAL "LLVMFlang")
  # This is for classic Flang. LLVM Flang is handled with gfortran below.
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_FLANG")
  if (BINARY64 AND INTERFACE64)
    set(FCOMMON_OPT "${FCOMMON_OPT} -i8")
  endif ()
  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -fopenmp")
  endif ()
  set(FCOMMON_OPT "${FCOMMON_OPT} -Mrecursive -Kieee")
endif ()

if (${F_COMPILER} STREQUAL "G77")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_G77")
  set(FCOMMON_OPT "${FCOMMON_OPT} -Wall")
  if (NOT NO_BINARY_MODE)
    if (BINARY64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -m64")
    else ()
      set(FCOMMON_OPT "${FCOMMON_OPT} -m32")
    endif ()
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "G95")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_G95")
  set(FCOMMON_OPT "${FCOMMON_OPT} -Wall")
  if (NOT NO_BINARY_MODE)
    if (BINARY64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -m64")
    else ()
      set(FCOMMON_OPT "${FCOMMON_OPT} -m32")
    endif ()
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "GFORTRAN" OR ${F_COMPILER} STREQUAL "F95" OR CMAKE_Fortran_COMPILER_ID STREQUAL "LLVMFlang")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_GFORT")
  if (NOT CMAKE_Fortran_COMPILER_ID STREQUAL "LLVMFlang")
    # ensure reentrancy of lapack codes
    set(FCOMMON_OPT "${FCOMMON_OPT} -Wall -frecursive")
    # work around ABI violation in passing string arguments from C
    set(FCOMMON_OPT "${FCOMMON_OPT} -fno-optimize-sibling-calls")
    if (NOT NO_LAPACK)
      # Don't include -lgfortran, when NO_LAPACK=1 or lsbcc
      set(EXTRALIB "${EXTRALIB} -lgfortran")
    endif ()
  endif ()
  if (NO_BINARY_MODE)
    if (MIPS64)
      if (BINARY64)
        set(FCOMMON_OPT "${FCOMMON_OPT} -mabi=64")
      else ()
        set(FCOMMON_OPT "${FCOMMON_OPT} -mabi=n32")
      endif ()
    endif ()
    if (LOONGARCH64)
      if (BINARY64)
        set(FCOMMON_OPT "${FCOMMON_OPT} -mabi=lp64")
      else ()
        set(FCOMMON_OPT "${FCOMMON_OPT} -mabi=lp32")
      endif ()
    endif ()
    if (RISCV64)
      if (BINARY64)
        if (INTERFACE64)
          set(FCOMMON_OPT "${FCOMMON_OPT} -fdefault-integer-8")
        endif ()
      endif ()
    endif ()
  else ()
    if (BINARY64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -m64")
      if (INTERFACE64)
        if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
          if (WIN32)
            set(FCOMMON_OPT "${FCOMMON_OPT} /integer-size:64")
          else ()
            set(FCOMMON_OPT "${FCOMMON_OPT} -integer-size 64")
          endif ()
        else ()
          set(FCOMMON_OPT "${FCOMMON_OPT} -fdefault-integer-8")
        endif ()
      endif ()
    else ()
      set(FCOMMON_OPT "${FCOMMON_OPT} -m32")
    endif ()
  endif ()

  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -fopenmp")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "INTEL")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_INTEL")
  if (INTERFACE64)
    set(FCOMMON_OPT "${FCOMMON_OPT} -i8")
  endif ()
  set(FCOMMON_OPT "${FCOMMON_OPT} -recursive")
  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -openmp")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "FUJITSU")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_FUJITSU")
  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -openmp")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "IBM")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_IBM")
  set(FCOMMON_OPT "${FCOMMON_OPT} -qrecur")
  if (BINARY64)
    set(FCOMMON_OPT "${FCOMMON_OPT} -q64")
    if (INTERFACE64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -qintsize=8")
    endif ()
  else ()
    set(FCOMMON_OPT "${FCOMMON_OPT} -q32")
  endif ()
  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -openmp")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "PGI" OR ${F_COMPILER} STREQUAL "PGF95")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_PGI")
  set(COMMON_PROF "${COMMON_PROF} -DPGICOMPILER")
  if (BINARY64)
    if (INTERFACE64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -i8")
    endif ()
    set(FCOMMON_OPT "${FCOMMON_OPT} -tp p7-64")
  else ()
    set(FCOMMON_OPT "${FCOMMON_OPT} -tp p7")
  endif ()
  set(FCOMMON_OPT "${FCOMMON_OPT} -Mrecursive")
  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -mp")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "PATHSCALE")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_PATHSCALE")
  if (BINARY64)
    if (INTERFACE64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -i8")
    endif ()
  endif ()

  if (NOT MIPS64)
    if (NOT BINARY64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -m32")
    else ()
      set(FCOMMON_OPT "${FCOMMON_OPT} -m64")
    endif ()
  else ()
    if (BINARY64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -mabi=64")
    else ()
    set(FCOMMON_OPT "${FCOMMON_OPT} -mabi=n32")
    endif ()
  endif ()

  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -mp")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "OPEN64")

  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_OPEN64")
  if (BINARY64)
    if (INTERFACE64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -i8")
    endif ()
  endif ()

  if (MIPS64)

    if (NOT BINARY64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -n32")
    else ()
      set(FCOMMON_OPT "${FCOMMON_OPT} -n64")
    endif ()

    if (${CORE} STREQUAL "LOONGSON3A")
      set(FCOMMON_OPT "${FCOMMON_OPT} -loongson3 -static")
    endif ()

    if (${CORE} STREQUAL "LOONGSON3B")
    set(FCOMMON_OPT "${FCOMMON_OPT} -loongson3 -static")
    endif ()
  else ()
    if (NOT BINARY64)
      set(FCOMMON_OPT "${FCOMMON_OPT} -m32")
    else ()
      set(FCOMMON_OPT "${FCOMMON_OPT} -m64")
    endif ()
  endif ()

  if (USE_OPENMP)
    set(FEXTRALIB "${FEXTRALIB} -lstdc++")
    set(FCOMMON_OPT "${FCOMMON_OPT} -mp")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "SUN")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_SUN")
  if (X86)
    set(FCOMMON_OPT "${FCOMMON_OPT} -m32")
  else ()
    set(FCOMMON_OPT "${FCOMMON_OPT} -m64")
  endif ()
  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -xopenmp=parallel")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "COMPAQ")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_COMPAQ")
  if (USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -openmp")
  endif ()
endif ()

if (${F_COMPILER} STREQUAL "CRAY")
  set(CCOMMON_OPT "${CCOMMON_OPT} -DF_INTERFACE_INTEL")
  set(FCOMMON_OPT "${FCOMMON_OPT} -hnopattern")
  if (INTERFACE64)
    set (FCOMMON_OPT "${FCOMMON_OPT} -s integer64")
  endif ()
  if (NOT USE_OPENMP)
    set(FCOMMON_OPT "${FCOMMON_OPT} -O noomp")
  endif ()
endif ()

# from the root Makefile - this is for lapack-netlib to compile the correct secnd file.
if (${F_COMPILER} STREQUAL "GFORTRAN")
  set(TIMER "INT_ETIME")
else ()
  set(TIMER "NONE")
endif ()

