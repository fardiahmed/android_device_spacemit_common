#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Use generic ramdisk (init_boot)
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Enable project quotas and casefolding for emulated storage without sdcardfs
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Dalvik heap config
$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

# GSI keys
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# API level
PRODUCT_SHIPPING_API_LEVEL := 35

# Set Vendor SPL to match platform
VENDOR_SECURITY_PATCH = $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH = $(PLATFORM_SECURITY_PATCH)

# A/B OTA
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_client \
    update_verifier \
    checkpoint_gc

# Boot control: the HAL only ships in its vendor APEX on Android 16.
PRODUCT_PACKAGES += \
    com.android.hardware.boot \
    android.hardware.boot-service.default_recovery

# bootctl CLI to inspect/set the A/B slot state.
PRODUCT_PACKAGES_DEBUG += bootctl

# Fastboot
PRODUCT_PACKAGES += \
    fastbootd \
    android.hardware.fastboot-service.example

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.example \
    android.hardware.health-service.example_recovery

# USB HAL (BayLibre generic)
PRODUCT_PACKAGES += \
    com.android.hardware.usb.generic

# Audio HAL: BayLibre generic APEX plus the Bluetooth audio VINTF fragment (audio/).
PRODUCT_PACKAGES += \
    com.spacemit.hardware.audio

PRODUCT_PACKAGES += \
    tinyplay2 \
    tinycap2 \
    tinymix2 \
    tinypcminfo2 \
    cplay

# Thermal HAL (BayLibre generic, v3)
PRODUCT_PACKAGES += \
    com.android.hardware.thermal.rs.generic.v3

# Power HAL
PRODUCT_PACKAGES += \
    com.android.hardware.power

# KeyMint (software, no TEE)
PRODUCT_PACKAGES += \
    com.android.hardware.keymint.rust_nonsecure

# Gatekeeper (software, no TEE — required for FBE /data encryption)
PRODUCT_PACKAGES += \
    com.android.hardware.gatekeeper.nonsecure

# Graphics - HWComposer + Gralloc
PRODUCT_PACKAGES += \
    android.hardware.composer.hwc3-service.drm \
    android.hardware.graphics.allocator-service.minigbm \
    mapper.minigbm

# Mesa3D GPU (PowerVR Vulkan + Zink OpenGL ES)
PRODUCT_PACKAGES += \
    libGLES_mesa \
    libGLESv1_CM_mesa \
    libGLESv2_mesa \
    libgallium_dri \
    vulkan.mesa \
    libgbm_mesa \
    dri_gbm \
    vulkan_mesa_icd \
    libgbm_mesa_wrapper

PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=196608 \
    persist.demo.rotationlock=1

PRODUCT_PACKAGES += \
    zink_dri \
    powervr_dri \
    spacemit_dri

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2022-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml

# Vulkan
TARGET_VULKAN_SUPPORT := true
TARGET_USES_VULKAN := true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.egl=mesa \
    ro.hardware.vulkan=mesa \
    debug.hwui.renderer=skiavk \
    debug.renderengine.backend=skiavkthreaded \
    vendor.gralloc.minigbm.backend=gbm_mesa \
    vendor.mesa.gbm_backends_path=/vendor/lib64/gbm

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@latest-service.clearkey

# Memtrack
PRODUCT_PACKAGES += \
    android.hardware.memtrack-service.example

# Dumpstate
PRODUCT_PACKAGES += \
    android.hardware.dumpstate-service.example

# HIDL compatibility
PRODUCT_PACKAGES += \
    hwservicemanager \
    android.hidl.allocator@1.0-service

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.secure_lock_screen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.secure_lock_screen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    device/linaro/hikey/etc/permissions/android.hardware.screen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.xml

# Bluetooth profiles (none are enabled by default); same set as hikey.
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.profile.a2dp.source.enabled?=true \
    bluetooth.profile.avrcp.target.enabled?=true \
    bluetooth.profile.hfp.ag.enabled?=true \
    bluetooth.profile.gatt.enabled?=true \
    bluetooth.profile.hid.host.enabled?=true \
    bluetooth.profile.hid.device.enabled?=true \
    bluetooth.profile.opp.enabled?=true \
    bluetooth.profile.pan.nap.enabled?=true \
    bluetooth.profile.pan.panu.enabled?=true \
    bluetooth.profile.asha.central.enabled?=true \
    bluetooth.profile.bap.broadcast.assist.enabled=false \
    bluetooth.profile.bap.unicast.client.enabled=false \
    bluetooth.profile.bas.client.enabled=false \
    bluetooth.profile.ccp.server.enabled=false \
    bluetooth.profile.csip.set_coordinator.enabled=false \
    bluetooth.profile.hap.client.enabled=false \
    bluetooth.profile.vcp.controller.enabled=false

# Audio configuration
PRODUCT_COPY_FILES += \
    device/spacemit/common/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    device/spacemit/common/audio/primary_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/primary_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/a2dp_in_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_in_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml \
    hardware/baylibre/audio/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects_config.xml \
    hardware/baylibre/audio/mixer_controls.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_controls.xml

# Media codecs
PRODUCT_COPY_FILES += \
	device/spacemit/common/android.hardware.media.c2-extended-seccomp_policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/android.hardware.media.c2-extended-seccomp_policy \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_audio.xml \
    device/spacemit/common/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    hardware/baylibre/usb \
    hardware/baylibre/audio \
    hardware/baylibre/thermal

# UI
PRODUCT_PACKAGES += \
    Launcher3QuickStep

# WebView provider (riscv64). Not K1-specific — shared by all SpacemiT K1-family
# boards. Chromium ships no official riscv64 WebView prebuilt, so import the
# locally-built system_webview_apk (com.android.webview) from common/webview/
# rather than patching external/chromium-webview (which would require forking
# that AOSP repo). com.android.webview is availableByDefault in config_webview_packages.xml.
PRODUCT_PACKAGES += webview_riscv64


# Storage: for factory reset protection feature
PRODUCT_PROPERTY_OVERRIDES += \
	ro.frp.pst=/dev/block/by-name/frp

# Overlays (stay-on, no lockscreen, navigation bar -- dev defaults for boards on a monitor).
# SPACEMIT_AUTO_ROTATE (spacemit-features.mk) appends overlay-autorotate after this one.
DEVICE_PACKAGE_OVERLAYS := device/spacemit/common/overlay

# ============================================================
# External USB camera support
# ============================================================
PRODUCT_PACKAGES += \
    android.hardware.camera.provider-V1-external-service

PRODUCT_COPY_FILES += \
    device/spacemit/common/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

# Codec2: use AIDL HAL so that app processes (e.g. scrcpy) can discover
# software codecs via IComponentStore/software instead of relying on the
# in-process ApexCodecs path that only works in system processes.
PRODUCT_PROPERTY_OVERRIDES += \
    media.c2.hal.selection=aidl \
    debug.stagefright.c2inputsurface=-1

# Vendor seccomp policy extension for media.swcodec.
# Allows syscalls needed by Mesa/Zink GPU init (sched_getaffinity, epoll, etc.)
# triggered via AHardwareBuffer_isSupported inside the mediaswcodec sandbox.
PRODUCT_COPY_FILES += \
    device/spacemit/common/seccomp_policy/mediaswcodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaswcodec.policy

# Soong namespaces for Mesa prebuilts and gbm_mesa_wrapper
PRODUCT_SOONG_NAMESPACES += vendor/spacemit/hardware/mesa
PRODUCT_SOONG_NAMESPACES += external/minigbm/gbm_mesa_driver

# Uncompressed APEXes: no size gain here, and first boot skips decompression.
PRODUCT_COMPRESSED_APEX := false
