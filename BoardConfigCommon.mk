#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Architecture
# TARGET_ARCH_VARIANT is set per-board (e.g. "x60" for K1) so that future
# SpaceMit SoCs with different CPU cores can override it independently.
TARGET_ARCH := riscv64
TARGET_ARCH_VARIANT :=
TARGET_CPU_ABI := riscv64
TARGET_CPU_VARIANT := generic

# 64-bit only
TARGET_SUPPORTS_32_BIT_APPS := false
TARGET_SUPPORTS_64_BIT_APPS := true

# Metadata partition (creates /metadata mount point in system image)
BOARD_USES_METADATA_PARTITION := true

# Bootloader
TARGET_NO_BOOTLOADER := true

# Kernel
TARGET_KERNEL_ARCH := riscv64
BOARD_KERNEL_CMDLINE := init=/init
BOARD_KERNEL_CMDLINE += firmware_class.path=/vendor/firmware
BOARD_KERNEL_CMDLINE += swiotlb=65536
BOARD_KERNEL_CMDLINE += deferred_probe_timeout=30

# Bring-up-only perf-killing flags removed on ALL build variants:
#   clk_ignore_unused / pd_ignore_unused : keep clocks/PD gates open, drives
#     idle power up and prevents the driver-quiescing path from running.
#   loglevel=8 / log_buf_len=32M       : forces every printk to the console
#     (~ms each) and inflates the log buffer 8x.  Major perf hit on all
#     variants (incl. userdebug).  Re-add temporarily if you need them
#     during a specific driver bring-up.
#   printk.devkmsg=on                  : exposes /dev/kmsg to userspace
#     readers, unnecessary in production and on dev builds with logcat.

# Console + early UART kept on userdebug/eng for boot diagnostics (low perf
# impact since they don't open PM gates or flood printk).
ifneq ($(TARGET_BUILD_VARIANT),user)
BOARD_KERNEL_CMDLINE += console=ttyS0,115200
BOARD_KERNEL_CMDLINE += earlycon=sbi earlycon=uart8250,mmio32,0xd4017000
BOARD_KERNEL_CMDLINE += earlyprintk
endif
# SPACEMIT_QUIET_BOOT=true: loglevel=4, the polled UART console costs seconds of boot.
ifeq ($(SPACEMIT_QUIET_BOOT),true)
BOARD_KERNEL_CMDLINE += loglevel=4
endif
# BOARD_KERNEL_CMDLINE += androidboot.first_stage_console=1


# Boot image
BOARD_BOOT_HEADER_VERSION := 4
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_RAMDISK_USE_LZ4 := true
BOARD_KERNEL_PAGESIZE := 4096
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION) --pagesize $(BOARD_KERNEL_PAGESIZE) --kernel_offset 0x200000

# Bootconfig
BOARD_BOOTCONFIG += androidboot.load_modules_parallel=true
BOARD_BOOTCONFIG += androidboot.logcat.buffersize=4M
# GKI
BOARD_USES_GENERIC_KERNEL_IMAGE := true

# Partition sizes
BOARD_BOOTIMAGE_PARTITION_SIZE := 41943040
# BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608

# Dynamic partitions
TARGET_USE_DYNAMIC_PARTITIONS := true
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
BOARD_SUPER_PARTITION_GROUPS := spacemit_dynamic_partitions
BOARD_SPACEMIT_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor vendor_dlkm system_dlkm

# Filesystem
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_COPY_OUT_VENDOR := vendor

# Vendor DLKM
BOARD_USES_VENDOR_DLKMIMAGE := true
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

# System DLKM
BOARD_USES_SYSTEM_DLKMIMAGE := true
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm

# A/B OTA
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS := boot system vendor vendor_boot init_boot vendor_dlkm system_dlkm vbmeta vbmeta_vendor_dlkm vbmeta_system_dlkm

# Recovery
TARGET_NO_RECOVERY := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

# AVB
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_INIT_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_INIT_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_VBMETA_CUSTOM_PARTITIONS := vendor_dlkm system_dlkm

BOARD_AVB_VBMETA_VENDOR_DLKM := vendor_dlkm
BOARD_AVB_VBMETA_VENDOR_DLKM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_VENDOR_DLKM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_VENDOR_DLKM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_VENDOR_DLKM_ROLLBACK_INDEX_LOCATION := 4

BOARD_AVB_VBMETA_SYSTEM_DLKM := system_dlkm
BOARD_AVB_VBMETA_SYSTEM_DLKM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_SYSTEM_DLKM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_SYSTEM_DLKM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_DLKM_ROLLBACK_INDEX_LOCATION := 5

# SELinux
BOARD_SEPOLICY_DIRS += device/spacemit/common/sepolicy/vendor
BOARD_SEPOLICY_DIRS += hardware/baylibre/usb/aidl/sepolicy

# VNDK
BOARD_VNDK_VERSION := current

# Temporary
ALLOW_MISSING_DEPENDENCIES := true
