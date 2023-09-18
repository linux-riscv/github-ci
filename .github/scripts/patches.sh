#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

. ${d}/helpers.sh

basesha=$(git log -1 --pretty=%H .github/scripts/helpers.sh)
patches=( $(git rev-list --reverse ${basesha}..HEAD) )

group_start "Per-patch"
rc=0
cnt=1
for i in "${patches[@]}"; do
    tests=( $(ls ${d}/patches/*.sh) )
    tcnt=1
    for j in "${tests[@]}"; do
        git reset --hard $i
        msg="Patch ${cnt}/${#patches[@]}: Test ${tcnt}/${#tests[@]}: ${j}"
        echo "::group::${msg} @ $(date --utc +%Y-%m-%dT%H:%M:%S.%NZ)"
        bash ${j} "${msg}" || rc=1
        echo "::endgroup::"
        echo "Completed $(date --utc +%Y-%m-%dT%H:%M:%S.%NZ)"
        tcnt=$(( tcnt + 1 ))
    done
    cnt=$(( cnt + 1 ))
done
group_end

exit $rc
