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

# Hardware codecs on the Linlon-V5 VPU (amvx) via external/v4l2_codec2.
SPACEMIT_HW_CODEC2 ?= true
ifeq ($(SPACEMIT_HW_CODEC2),true)
PRODUCT_SOONG_NAMESPACES += \
    external/v4l2_codec2 \
    vendor/spacemit/hardware/codec2
PRODUCT_PACKAGES += \
    android.hardware.media.c2-service.k1-v4l2
endif
