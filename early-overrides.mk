#
# Copyright (C) 2024 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Replacements of AOSP default files. PRODUCT_COPY_FILES is first-wins, so every
# product inherits this file before full_base.mk.

# preloaded-classes without android.renderscript.* (not built on RISC-V).
PRODUCT_COPY_FILES += \
    device/spacemit/common/preloaded-classes:system/etc/preloaded-classes
