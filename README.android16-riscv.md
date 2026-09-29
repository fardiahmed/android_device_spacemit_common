# A16_RISCV/device/spacemit/common: android16-riscv

Changes made for the Android 16 (AOSP, riscv64) bring-up of the BananaPi BPI-F3 (SpacemiT K1) and the BananaPi BPI-SM10 (SpacemiT K3), on branch `android16-riscv`.

Configuration shared by the SpacemiT K1 and K3 boards.

## Changes

- **common: move the SoC-independent configuration from k1**: Prepare for more SpacemiT SoCs (K3): audio policy, overlays, USB camera, Codec2 AIDL selection, swcodec seccomp and preloaded-classes move here from device/spacemit/k1 (the Mesa prebuilts to vendor/spacemit/hardware/mesa), and the K1-only fstab, init and GPU firmware move there. Add spacemit-features.mk for the optional SPACEMIT_* features.
- **common: install the boot control HAL from its vendor APEX**: android.hardware.boot-service.default is installable: false in Android 16, so no IBootControl was registered and the A/B slot was never marked successful. Add the bootctl CLI to debug builds.
- **common: add the SPACEMIT_QUIET_BOOT build option**: loglevel=4: the polled 115200-baud console costs ~9 s of boot time.
- **common: add the SPACEMIT_DEVKMSG_UNLIMITED build option**: printk.devkmsg=on to debug recovery, which only logs through /dev/kmsg.
- **common: allow riscv_hwprobe in the extended Codec2 seccomp policy**: Mesa, loaded in the codec service by minigbm's gbm_mesa backend, calls riscv_hwprobe; the service died with SIGSYS at the first decode.
- **common: add a SpacemiT audio APEX with the Bluetooth audio fragment**: The BayLibre generic APEX lacks the IBluetoothAudioProviderFactory VINTF fragment, so A2DP could never start.
- **common: declare the Bluetooth features**
- **common: enable the usual Bluetooth profiles**: The stack enables none by default (no A2DP source to a speaker); same set as hikey.
- **common: ship APEXes uncompressed**: The capex files are about as large as their payload, and first boot no longer decompresses ~165 MB.
- **common: add an HDMI output to the primary audio policy**: Routes playback to the K1-HDMI sound card when a monitor is connected.
- **common: label the minigbm stable-C mapper service**
- **common: show the navigation bar and use input events for the audio jack**
- **common: add the SPACEMIT_MICROG and SPACEMIT_AVF_ENABLED feature flags**: AVF stays off by default: the K1 has no H extension and rkpd kept failing to start virtualizationservice.
- **common: enable the Codec2 service for the SpacemiT VPU**: AIDL Codec2 service (vendor/spacemit/hardware/codec2) serving external/v4l2_codec2's V4L2 components (amvx VPU): H.264/HEVC/VP8/VP9 decode, H.264/VP8/VP9 encode. SPACEMIT_HW_CODEC2.
- **common: add the SPACEMIT_HDMI_CEC feature flag**: HDMI-CEC as a playback device, with the vendor/spacemit/hardware/hdmi HAL.
- **common: add the SPACEMIT_WFD_SINK feature flag**: WfdSink Miracast receiver (vendor/spacemit/apps/WfdSink): screen mirroring from phones/PCs over Wi-Fi Direct.
- **common: add the SPACEMIT_EXOPLAYER feature flag**
- **common: add the SPACEMIT_MIC_TEST feature flag**: MicTest app (vendor/spacemit/apps/MicTest) for the built-in microphones.
- **common: add the on-device LLM feature**: llama-server/cli/bench (vendor/spacemit/ai/llama) and the AI Chat app (vendor/spacemit/apps/AiChat), with their SELinux domain and properties. SPACEMIT_LLM.
- **common: add the header sensors HAL and auto-rotation**: Sensors HAL (vendor/spacemit/hardware/sensors) for the header I2C4 modules (MPU-9250, AHT20, BMP280) and accelerometer auto-rotation. SPACEMIT_SENSORS, SPACEMIT_AUTO_ROTATE; the rotation lock is only set when auto-rotation is off.
- **common: let boards and products replace default files**: PRODUCT_COPY_FILES keeps the first entry for a destination and inherited files come first, so the generic mixer_controls.xml here and AOSP's preloaded-classes silently won over the device ones. mixer_controls.xml is now per board; early-overrides.mk (inherited first) replaces preloaded-classes.
- **common: add build.sh to build the kernel, bootloaders and images from source**: Builds the Kleaf kernel dist (kernel/spacemit) into device/spacemit/<soc>-kernel/mainline, the K1 bootloaders (bootloader/spacemit) into vendor/spacemit/{k1,musepi-pro}/bootloader, then lunch + m, so no kernel or bootloader prebuilts are kept in git. The manifest links it to the tree root as build.sh; build/find-ignore becomes kernel/spacemit/.find-ignore and bootloader/spacemit/.find-ignore so Soong skips those workspaces.
- **common: build the OP-TEE KeyMint/Gatekeeper TAs in build.sh**: After the bootloaders, build the vendor/spacemit/hardware/optee_keymint TAs with the TA dev kit of the OP-TEE build (same signing key) and stage them in vendor/spacemit/<soc>/optee for the vendor image.
- **common: run KeyMint and Gatekeeper in OP-TEE**: SPACEMIT_OPTEE (default on) replaces the software KeyMint/Gatekeeper APEXes with the OP-TEE HALs of vendor/spacemit/hardware/optee_keymint, tee-supplicant (external/optee_client) and the TAs staged by build.sh. The TA secure storage is on persist, since KeyMint is needed before /data is mounted.
- **common: stop build.sh when a step fails**: set -e does not apply inside an && list, so a failed kernel build still exited 0.
- **common: build the BPI-SM10 bootloaders in build.sh**: `./build.sh k3` builds the bananapi-sm10 bootloader board (BayLibre K3 U-Boot 2026.07 + OpenSBI) into vendor/spacemit/k3/bootloader.

## Notes

- Optional features are `SPACEMIT_<NAME>` flags in `spacemit-features.mk` (`?=` defaults); a SoC `device.mk` forces unsupported ones off with `:=` before inheriting it.
- `early-overrides.mk` must be inherited first by every product (PRODUCT_COPY_FILES is first-wins).
- `webview/SystemWebView64.apk` is a Git LFS object: push with git-lfs installed.
- Only configuration lives here: the HALs, services, Mesa prebuilts and apps are repositories of their own under vendor/spacemit/{hardware,apps}.
- `build/build.sh` (linked as `build.sh` at the tree root by the local manifest) builds the kernel from `kernel/spacemit` and the K1 bootloaders from `bootloader/spacemit` (local manifest `spacemit-sources.xml`), stages them into device/spacemit/<soc>-kernel/mainline and vendor/spacemit/{k1,musepi-pro}/bootloader, then runs lunch + m. No kernel or bootloader prebuilts are kept in git.
- `jobs=N ./build.sh k1` (or `-j N`) limits the parallel jobs of the kernel, bootloader and Android builds, e.g. `jobs=12` on hosts that are unstable under full load.
- Before each kernel build, `build.sh` switches `kernel/spacemit/prebuilts/{clang/host/linux-x86,rust-toolchain/linux-x86}` to a sparse checkout of the versions pinned in `common/bazel/constants.scl` (about 20 GB less). Android's own `prebuilts/clang` cannot be reused: the kernel needs a newer clang (r596125) than Android 16 ships. Undo with `git -C <dir> sparse-checkout disable`.
- `build/find-ignore` is linked as `.find-ignore` into both workspaces so Soong does not scan them.
- `SPACEMIT_OPTEE`: KeyMint/Gatekeeper TAs run in OP-TEE (`bootloader/spacemit/optee_os`, OpenSBI trusted domain). `init.optee.rc` starts tee-supplicant at post-fs, before the `early_hal` KeyMint that vold needs to unlock `/data`; OP-TEE's REE FS secure storage is in `/mnt/vendor/persist/tee` (first-stage mounted), set with the `optee_client` Soong config `cfg_tee_fs_parent_path`. No hardware unique key and no RPMB yet: development-grade storage. Off: the software `rust_nonsecure` KeyMint and `nonsecure` Gatekeeper APEXes (selected by bootconfig in BoardConfigCommon.mk).
- The TAs come from `./build.sh k1` (bootloader step) into `vendor/spacemit/k1/optee`; without them the build warns and KeyMint cannot start.

## Build

```
./build.sh k1   # BPI-F3 (K1): kernel, bootloaders and Android images
./build.sh k3   # BPI-SM10 (K3), not booted yet
```

`./build.sh --help` lists the options (`--skip-kernel`, `--kernel-only`, ...).
