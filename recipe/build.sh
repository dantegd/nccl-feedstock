#!/bin/bash

EXTRA_ARGS=""

if [[ "${cuda_compiler_version}" =~ 12.* ]]; then
  EXTRA_ARGS="${EXTRA_ARGS} CUDA_HOME=${PREFIX} NVCC=${BUILD_PREFIX}/bin/nvcc"

  [[ "${target_platform}" == "linux-64" ]] && targetsDir="targets/x86_64-linux"
  [[ "${target_platform}" == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
  [[ "${target_platform}" == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

  export CFLAGS="${CFLAGS} -I${BUILD_PREFIX}/${targetsDir}/include"
  export CXXFLAGS="${CXXFLAGS} -I${BUILD_PREFIX}/${targetsDir}/include"

elif [[ "${cuda_compiler_version}" != "None" ]]; then
  EXTRA_ARGS="${EXTRA_ARGS} CUDA_HOME=${CUDA_PATH}"
fi

if [[ $target_platform == linux-aarch64 || ($target_platform == linux-ppc64le && $cuda_compiler_version != "10.2")]]; then
    # it takes too much time to compile, so we reduce the supported archs on aarch64
    export NVCC_GENCODE="-gencode=arch=compute_60,code=[compute_60,sm_60] \
                         -gencode=arch=compute_70,code=[compute_70,sm_70] \
                         -gencode=arch=compute_80,code=[compute_80,sm_80]"
    make -j${CPU_COUNT} src.lib CUDARTLIB="cudart_static" NVCC_GENCODE="$NVCC_GENCODE" ${EXTRA_ARGS}
else
    make -j${CPU_COUNT} src.lib CUDARTLIB="cudart_static" ${EXTRA_ARGS}
fi

make install PREFIX="${PREFIX}"

# Delete static library
rm "${PREFIX}/lib/libnccl_static.a"
