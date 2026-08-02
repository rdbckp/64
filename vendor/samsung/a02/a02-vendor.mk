$(call inherit-product, vendor/samsung/a02/configs/board.mk)

PRODUCT_PACKAGES += \
    libmtk_symbols \
    libmtk_vendor

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.device=a02 \
    ro.vendor.model=Galaxy\ A02 \
    ro.vendor.product.device=a02 \
    ro.vendor.product.model=Galaxy\ A02 \
    ro.vendor.extension_library=/vendor/lib64/libqti-perfd-client.so

# 64-bit Specific: VINTF Manifest Declaration (Treble)
DEVICE_MANIFEST_FILE += vendor/samsung/a02/manifest.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/manifest.xml:$(TARGET_COPY_OUT_VENDOR)/etc/vintf/manifest.xml
