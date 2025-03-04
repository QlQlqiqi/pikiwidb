#!/bin/bash

#color code
C_RED="\033[31m"
C_GREEN="\033[32m"

C_END="\033[0m"

BUILD_TIME=$(git log -1 --format=%ai)
BUILD_TIME=${BUILD_TIME: 0: 10}

COMMIT_ID=$(git rev-parse HEAD)
SHORT_COMMIT_ID=${COMMIT_ID: 0: 8}

BUILD_TYPE=Release
VERBOSE=0
CMAKE_FLAGS=""
MAKE_FLAGS=""
PREFIX="cmake-build"

ARGS=`getopt -a -o h -l help,debug,verbose,prefix: -- "$@"`
function show_help() {
  echo "
  -h --help   show help
  --debug     compile with debug
  --verbose   compile with verbose
  --prefix    compile output path
  "
  exit 0
}

eval set -- "${ARGS}"
while true
do
      case "$1" in
      -h|--help)
              show_help
              ;;
      --debug)
              BUILD_TYPE=debug
              ;;
      --verbose)
              CMAKE_FLAGS="${CMAKE_FLAGS} -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
              MAKE_FLAGS="${MAKE_FLAGS} VERBOSE=1"
              ;;
      --prefix)
              PREFIX=$2
              shift
              ;;
      --)
              shift
              break
              ;;
      esac
shift
done

if [ ! -f "/proc/cpuinfo" ];then
  CPU_CORE=$(sysctl -n hw.ncpu)
else
  CPU_CORE=$(cat /proc/cpuinfo| grep "processor"| wc -l)
fi
if [ ${CPU_CORE} -eq 0 ]; then
  CPU_CORE=1
fi

echo "cpu core ${CPU_CORE}"

echo "BUILD_TYPE:" $BUILD_TYPE
echo "CMAKE_FLAGS:" $CMAKE_FLAGS
echo "MAKE_FLAGS:" $MAKE_FLAGS

if [ "${BUILD_TYPE}" == "Release" ]; then
  PREFIX="${PREFIX}-release"
else
  PREFIX="${PREFIX}-debug"
fi

cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ${CMAKE_FLAGS} -S . -B ${PREFIX}
cmake --build ${PREFIX} -- ${MAKE_FLAGS} -j ${CPU_CORE}

if [ $? -eq 0 ]; then
    echo -e "pikiwidb compile complete, output file ${C_GREEN} ${BUILD_DIR}/pikiwidb ${C_END}"
else
    echo -e "${C_RED} pikiwidb compile fail ${C_END}"
    exit 1
fi
