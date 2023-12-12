#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

firmware_dir=/firmware

fw_rv32_opensbi=$(echo ${firmware_dir}/firmware_rv32_opensbi_*.tar.xz)
fw_rv64_opensbi=$(echo ${firmware_dir}/firmware_rv64_opensbi_*.tar.xz)
fw_rv64_uboot=$(echo ${firmware_dir}/firmware_rv64_uboot_*.tar.xz)
fw_rv64_edk2=$(echo ${firmware_dir}/firmware_rv64_edk2_*.tar.xz)

mkdir -p /fw/rv32
mkdir -p /fw/rv64

tar -C /fw/rv32 -xf $fw_rv32_opensbi

tar -C /fw/rv64 -xf $fw_rv64_opensbi
tar -C /fw/rv64 -xf $fw_rv64_uboot
tar -C /fw/rv64 -xf $fw_rv64_edk2
