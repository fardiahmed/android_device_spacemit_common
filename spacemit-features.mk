#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Optional features (SPACEMIT_<NAME>, true/false), defaults with ?=. A SoC device.mk forces
# unsupported ones off with := before inheriting this file (last).

# microG (Play services replacement) from vendor/microg.
SPACEMIT_MICROG ?= true
ifeq ($(SPACEMIT_MICROG),true)
$(call inherit-product-if-exists, vendor/microg/microg.mk)
endif

# AVF (crosvm, virtmgr): needs the RISC-V H extension, off by default (K1 has none).
SPACEMIT_AVF_ENABLED ?= false
ifeq ($(SPACEMIT_AVF_ENABLED),true)
PRODUCT_AVF_ENABLED := true
else
PRODUCT_AVF_ENABLED := false
PRODUCT_AVF_REMOTE_ATTESTATION_DISABLED := true
endif

# KeyMint and Gatekeeper in OP-TEE (vendor/spacemit/hardware/optee_keymint, TAs built by build.sh
# into vendor/spacemit/k1/optee). Off: software KeyMint/Gatekeeper, no TEE.
SPACEMIT_OPTEE ?= true
ifeq ($(SPACEMIT_OPTEE),true)
PRODUCT_PACKAGES += \
    tee-supplicant \
    android.hardware.security.keymint-service.optee \
    android.hardware.gatekeeper-service.optee
# KeyMint starts before /data is mounted: keep the TA secure storage on persist.
$(call soong_config_set,optee_client,cfg_tee_fs_parent_path,/mnt/vendor/persist/tee)
SPACEMIT_OPTEE_TAS := $(wildcard vendor/spacemit/k1/optee/*.ta)
ifeq ($(SPACEMIT_OPTEE_TAS),)
$(warning SPACEMIT_OPTEE: no TA in vendor/spacemit/k1/optee, build them with ./build.sh k1)
endif
PRODUCT_COPY_FILES += \
    $(foreach ta,$(SPACEMIT_OPTEE_TAS),$(ta):$(TARGET_COPY_OUT_VENDOR)/lib/optee_armtz/$(notdir $(ta))) \
    device/spacemit/common/init.optee.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.optee.rc
else
PRODUCT_PACKAGES += \
    com.android.hardware.keymint.rust_nonsecure \
    com.android.hardware.gatekeeper.nonsecure
endif

# Hardware codecs on the Linlon-V5 VPU (amvx) via external/v4l2_codec2.
SPACEMIT_HW_CODEC2 ?= true
ifeq ($(SPACEMIT_HW_CODEC2),true)
PRODUCT_SOONG_NAMESPACES += \
    external/v4l2_codec2 \
    vendor/spacemit/hardware/codec2
PRODUCT_PACKAGES += \
    android.hardware.media.c2-service.k1-v4l2
endif

# HDMI-CEC as a playback device (K1 cec-gpio + vendor/spacemit/hardware/hdmi HAL).
SPACEMIT_HDMI_CEC ?= true
ifeq ($(SPACEMIT_HDMI_CEC),true)
PRODUCT_PACKAGES += \
    android.hardware.tv.hdmi-service.k1
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.hdmi.cec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.hdmi.cec.xml
PRODUCT_VENDOR_PROPERTIES += \
    ro.hdmi.device_type=4
endif

# Miracast sink app (vendor/spacemit/apps/WfdSink); needs Wi-Fi Direct and the H.264 decoder.
SPACEMIT_WFD_SINK ?= true
ifeq ($(SPACEMIT_WFD_SINK),true)
PRODUCT_PACKAGES += \
    WfdSink
endif

# ExoPlayer demo app (vendor/spacemit/apps/ExoPlayer prebuilt).
SPACEMIT_EXOPLAYER ?= true
ifeq ($(SPACEMIT_EXOPLAYER),true)
PRODUCT_PACKAGES += \
    ExoPlayerDemo
endif

# Mic Test app (vendor/spacemit/apps/MicTest) for the built-in microphones.
SPACEMIT_MIC_TEST ?= true
ifeq ($(SPACEMIT_MIC_TEST),true)
PRODUCT_PACKAGES += \
    MicTest
endif

# On-device LLM: llama-server/cli/bench and the AI Chat app (vendor/spacemit/ai/llama, vendor/spacemit/apps/AiChat).
SPACEMIT_LLM ?= true
ifeq ($(SPACEMIT_LLM),true)
PRODUCT_PACKAGES += \
    llama-server \
    llama-cli \
    llama-bench \
    AiChat
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.llm.enable=1
endif

# Sensors HAL for the header I2C4 modules (MPU-9250 IMU, AHT20, BMP280).
SPACEMIT_SENSORS ?= true
ifeq ($(SPACEMIT_SENSORS),true)
PRODUCT_PACKAGES += \
    android.hardware.sensors-service.spacemit
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
    frameworks/native/data/etc/android.hardware.sensor.relative_humidity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.relative_humidity.xml
# Auto-rotation from the accelerometer; when off, the screen is locked landscape
# (persist.demo.rotationlock).
SPACEMIT_AUTO_ROTATE ?= true
ifeq ($(SPACEMIT_AUTO_ROTATE),true)
DEVICE_PACKAGE_OVERLAYS += device/spacemit/common/overlay-autorotate
endif

# IMU axis remap for a rotated module, e.g. "-y,x,z".
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.sensors.imu.axes=x,y,z
endif

ifneq ($(SPACEMIT_SENSORS)-$(SPACEMIT_AUTO_ROTATE),true-true)
PRODUCT_PROPERTY_OVERRIDES += \
    persist.demo.rotationlock=1
endif
