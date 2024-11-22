#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euox pipefail
d=$(dirname "${BASH_SOURCE[0]}")
. $d/series/utils.sh

logs=$(get_logs_dir)
f=${logs}/ltp.log

date -Iseconds | tee -a ${f}
echo "Build, boot, and run ltp on various kernels" | tee -a ${f}
echo "Top 16 commits" | tee -a ${f}
git log -16 --abbrev=12 --pretty="commit %h (\"%s\")" | tee -a ${f}
build_name=`git describe --tags`

# Build the kernel that will run LTP
export CI_TRIPLE="riscv64-linux-gnu"
cp $d/series/kconfigs/ubuntu_defconfig arch/riscv/configs/
$d/series/kernel_builder.sh rv64 ltp plain gcc
KERNEL_PATH=$(find "/build/$(gen_kernel_name rv64 ltp plain gcc)" -name '*vmlinuz*')
mv $KERNEL_PATH $KERNEL_PATH.gz
gunzip $KERNEL_PATH.gz

# Clone our own tuxrun
# FIXME: did not find a way to set qemu cpu using QEMU_CPU
cd /build
git clone https://gitlab.com/alexghiti/tuxrun -b dev/alex/riscv64

python3 -m venv .env
source .env/bin/activate
pip install -U tuxrun

# TODO ltp-controllers is too slow for now because of cgroup_fj_stress.sh
# but I haven't found an easy to skip this one from tuxrun
ltp_tests=( "ltp-commands"  "ltp-syscalls" "ltp-mm" "ltp-hugetlb" "ltp-crypto" "ltp-cve" "ltp-containers" "ltp-fs" "ltp-sched" )

mkdir -p /build/squad_json/

for ltp_test in ${ltp_tests[@]}; do
    ./tuxrun/run --runtime null --device qemu-riscv64 --kernel $KERNEL_PATH --tests $ltp_test --results /build/squad_json/$ltp_test.json --log-file-text /build/squad_json/$ltp_test.log --timeouts $ltp_test=480 || true

    # Convert JSON to squad datamodel
    python3 /build/my-linux/.github/scripts/series/tuxrun_to_squad_json.py --result-path /build/squad_json/$ltp_test.json
    python3 /build/my-linux/.github/scripts/series/generate_metadata.py --logs-path /build/squad_json/ --job-url ${GITHUB_JOB_URL}

    curl --header "Authorization: token $SQUAD_TOKEN" --form tests=@/build/squad_json/$ltp_test.squad.json --form log=@/build/squad_json/$ltp_test.log --form metadata=@/build/squad_json/metadata.json https://mazarinen.tail1c623.ts.net/api/submit/riscv-linux/linux-all/$build_name/qemu
done
