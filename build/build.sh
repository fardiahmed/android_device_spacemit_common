#!/bin/bash
# Builds the SpacemiT kernel and bootloaders from source, stages them where the device
# makefiles expect them, then builds the Android images. Linked as build.sh at the tree root.

set -euo pipefail

TOP=$(readlink -f "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../../../..")
KERNEL_DIR="${TOP}/kernel/spacemit"
BL_DIR="${TOP}/bootloader/spacemit"

usage() {
    cat <<EOF
usage: $(basename "$0") <k1|k3> [options] [-- <m arguments>]

  k1                    BananaPi BPI-F3 (+ MusePi Pro bootloader)
  k3                    BananaPi BPI-SM10 (no bootloader sources yet)

options:
  -p, --product NAME    lunch product (default: aosp_bananapi_f3_tablet / aosp_bananapi_sm10_tablet)
  -v, --variant NAME    userdebug (default), eng or user
  -r, --release NAME    release config (default: trunk_staging)
  -j, --jobs N          parallel jobs for the kernel, bootloader and Android builds
                        (default: \$jobs, else each tool's own default, usually all CPUs)
  --skip-kernel         reuse the staged kernel
  --skip-bootloader     reuse the staged bootloaders
  --skip-android        stop after the kernel and bootloaders
  --kernel-only         same as --skip-bootloader --skip-android
  --bootloader-only     same as --skip-kernel --skip-android
  -h, --help

environment:
  jobs                  same as --jobs, e.g. jobs=16 ./build.sh k1
  KLEAF_ARGS            extra Kleaf arguments (default: --config=fast)

outputs:
  kernel      device/spacemit/<soc>-kernel/mainline
  bootloader  vendor/spacemit/{k1,musepi-pro}/bootloader
  images      out/target/product/<device>
EOF
}

die() { echo "build.sh: $*" >&2; exit 1; }
step() { echo; echo "=== $(date +%T) $* ==="; }

soc=""
product=""
variant="userdebug"
release="trunk_staging"
jobs="${jobs:-}"
do_kernel=true
do_bootloader=true
do_android=true
m_args=()

while [ $# -gt 0 ]; do
    case "$1" in
        k1|k3) soc="$1" ;;
        -p|--product) product="$2"; shift ;;
        -v|--variant) variant="$2"; shift ;;
        -r|--release) release="$2"; shift ;;
        -j|--jobs) jobs="$2"; shift ;;
        -j*) jobs="${1#-j}" ;;
        --jobs=*) jobs="${1#--jobs=}" ;;
        --skip-kernel) do_kernel=false ;;
        --skip-bootloader) do_bootloader=false ;;
        --skip-android) do_android=false ;;
        --kernel-only) do_bootloader=false; do_android=false ;;
        --bootloader-only) do_kernel=false; do_android=false ;;
        -h|--help) usage; exit 0 ;;
        --) shift; m_args=("$@"); break ;;
        *) usage >&2; die "unknown argument: $1" ;;
    esac
    shift
done

case "${soc}" in
    k1)
        product="${product:-aosp_bananapi_f3_tablet}"
        kleaf_target="//devices/spacemit/bananapi_f3:spacemit_k1x_dist"
        bl_boards=(spacemit-k1 spacemit-musepi-pro)
        ;;
    k3)
        product="${product:-aosp_bananapi_sm10_tablet}"
        kleaf_target="//devices/spacemit/bananapi_sm10:spacemit_k3_dist"
        bl_boards=()
        ;;
    *) usage >&2; die "choose k1 or k3" ;;
esac
kernel_out="${TOP}/device/spacemit/${soc}-kernel/mainline"
case "${jobs}" in
    "") ;;
    *[!0-9]*|0) die "jobs must be a positive number: ${jobs}" ;;
esac

# Soong must not scan the kernel/bootloader workspaces (duplicate Android.bp modules).
for d in "${KERNEL_DIR}" "${BL_DIR}"; do
    [ -d "${d}" ] && [ ! -e "${d}/.find-ignore" ] && touch "${d}/.find-ignore"
done

# Sparse checkout of a prebuilts project: only the given (non-cone) patterns stay in the worktree.
sparse() {
    local dir="$1"; shift
    [ -e "${dir}/.git" ] || return 0
    [ "$(git -C "${dir}" sparse-checkout list 2>/dev/null)" = "$(printf '%s\n' "$@")" ] && return 0
    echo "sparse checkout ${dir#"${TOP}"/}: $*"
    git -C "${dir}" sparse-checkout set --no-cone "$@"
}

# Kleaf only uses the clang and Rust versions pinned in common/bazel/constants.scl: drop the
# other versions from the worktree (~20 GB). Undo with: git -C <dir> sparse-checkout disable
trim_kernel_prebuilts() {
    local constants="${KERNEL_DIR}/common/bazel/constants.scl" clang rustc
    [ -f "${constants}" ] || return 0
    clang=$(sed -n 's/^CLANG_VERSION="\(.*\)"$/\1/p' "${constants}")
    rustc=$(sed -n 's/^RUSTC_VERSION="\(.*\)"$/\1/p' "${constants}")
    [ -n "${clang}" ] && sparse "${KERNEL_DIR}/prebuilts/clang/host/linux-x86" \
        '/*' '!/clang-r*/' "/clang-${clang}/"
    [ -n "${rustc}" ] && sparse "${KERNEL_DIR}/prebuilts/rust-toolchain/linux-x86" \
        '/*' '!/[0-9]*/' "/${rustc}/"
    return 0
}

build_kernel() {
    step "kernel: ${kleaf_target}"
    [ -x "${KERNEL_DIR}/tools/bazel" ] || die "${KERNEL_DIR} is not synced (repo sync)"
    trim_kernel_prebuilts
    local dist="${KERNEL_DIR}/out/android-dist/${soc}"
    rm -rf "${dist}"
    # shellcheck disable=SC2086
    (cd "${KERNEL_DIR}" && tools/bazel run ${KLEAF_ARGS:---config=fast} ${jobs:+--jobs=${jobs}} \
        "${kleaf_target}" -- \
        --destdir="${dist}")
    mkdir -p "${kernel_out}"
    rsync -a --delete "${dist}/" "${kernel_out}/"
    echo "kernel staged in ${kernel_out#"${TOP}"/}"
}

build_bootloader() {
    if [ ${#bl_boards[@]} -eq 0 ]; then
        echo "no bootloader sources for ${soc}: skipped"
        return
    fi
    local release_sh="${BL_DIR}/build-bootloaders/release_android.sh"
    [ -x "${release_sh}" ] || die "${BL_DIR} is not synced (repo sync)"
    for board in "${bl_boards[@]}"; do
        step "bootloader: ${board}"
        # The bootloader scripts run make -j$(nproc); nproc honours OMP_NUM_THREADS.
        OMP_NUM_THREADS="${jobs:-$(nproc)}" "${release_sh}" --aosp="${TOP}" --mode=release \
            --config="${BL_DIR}/build-bootloaders/config/boards/${board}.yaml"
    done
}

build_android() {
    # -jN first so an explicit -j after -- still wins.
    [ -n "${jobs}" ] && m_args=("-j${jobs}" "${m_args[@]}")
    step "android: ${product}-${release}-${variant} m ${m_args[*]:-}"
    cd "${TOP}"
    set +eu
    # shellcheck disable=SC1091
    source build/envsetup.sh >/dev/null
    lunch "${product}" "${release}" "${variant}" || exit 1
    m "${m_args[@]}" || exit $?
}

[ "${do_kernel}" = true ] && build_kernel
[ "${do_bootloader}" = true ] && build_bootloader
[ "${do_android}" = true ] && build_android
step "done"
