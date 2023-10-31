#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

kernels_dir=/kernels
firmware_dir=/firmware
rootfs_dir=/rootfs

xlen=$1
config=$2
fragment=$3
toolchain=$4
rootfs=$5

lnx="${kernels_dir}/linux_${xlen}_${toolchain}_${config//_/-}_$(basename $fragment).tar.xz"
rootfs=$(echo ${rootfs_dir}/rootfs_${xlen}_${rootfs}_*.tar.xz)
fw_rv32_opensbi=$(echo ${firmware_dir}/firmware_rv32_opensbi_*.tar.xz)
fw_rv64_opensbi=$(echo ${firmware_dir}/firmware_rv64_opensbi_*.tar.xz)
fw_rv64_uboot=$(echo ${firmware_dir}/firmware_rv64_uboot_*.tar.xz)
fw_rv64_edk2=$(echo ${firmware_dir}/firmware_rv64_edk2_*.tar.xz)

echo "::group::Testing ${lnx} ${rootfs}"
rc=0
$d/run_test.sh "${lnx}" "${rootfs}" "${fw_rv32_opensbi}" "${fw_rv64_opensbi}" \
               "${fw_rv64_uboot}" "${fw_rv64_edk2}" || rc=$?
echo "::endgroup::"
if (( $rc )); then
    echo "::error::FAIL ${lnx} ${rootfs}"
else
    echo "::notice::OK ${lnx} ${rootfs}"
fi
