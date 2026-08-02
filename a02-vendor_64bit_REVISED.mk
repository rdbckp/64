# Revised for 64-bit vendor partition
# Copy to: vendor/samsung/a02/a02-vendor.mk

$(call inherit-product, vendor/samsung/a02/configs/board.mk)

# ============================================================
# Minimal Vendor Packages
# ============================================================
# NOTE: libmtk_symbols and libmtk_vendor are typically 32-bit
# For first-boot test, these can be skipped or provided as stubs
PRODUCT_PACKAGES += \
    libmtk_symbols \
    libmtk_vendor

# ============================================================
# Vendor Properties
# ============================================================
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.device=a02 \
    ro.vendor.model=Galaxy\ A02 \
    ro.vendor.product.device=a02 \
    ro.vendor.product.model=Galaxy\ A02 \
    ro.vendor.extension_library=/vendor/lib64/libqti-perfd-client.so

# ============================================================
# 64-bit Specific Configuration
# ============================================================

# VINTF Manifest Declaration (Treble compatibility)
# This tells the system what HALs are available in vendor partition
DEVICE_MANIFEST_FILE += vendor/samsung/a02/manifest.xml

# Vendor partition configuration
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/manifest.xml:$(TARGET_COPY_OUT_VENDOR)/etc/vintf/manifest.xml

# ============================================================
# Future: HAL Packages (will be added in Phase 2)
# ============================================================
# PRODUCT_PACKAGES += \
#     android.hardware.graphics.allocator@3.0 \
#     android.hardware.graphics.composer@2.1 \
#     android.hardware.power@1.2 \
#     android.hardware.lights@2.0 \
#     android.hardware.vibrator@1.3
#
# These will be added after verifying basic boot works
