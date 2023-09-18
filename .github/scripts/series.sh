#!/bin/bash
# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

d=$(dirname "${BASH_SOURCE[0]}")

. ${d}/helpers.sh

group_start "Series"
rc=0
tcnt=1
tests=( $(ls ${d}/series/*.sh) )
for i in "${tests[@]}"; do
    git reset --hard HEAD
    msg="Test ${tcnt}/${#tests[@]}: ${i}"
    echo "::group::${msg} @ $(date --utc +%Y-%m-%dT%H:%M:%S.%NZ)"
    bash ${i} "${msg}" || rc=1
    echo "::endgroup::"
    echo "Completed $(date --utc +%Y-%m-%dT%H:%M:%S.%NZ)"
    tcnt=$(( tcnt + 1 ))
done
group_end

exit $rc
