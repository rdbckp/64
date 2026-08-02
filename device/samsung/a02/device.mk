LOCAL_PATH := device/samsung/a02

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

PRODUCT_AAPT_PREF_CONFIG := mdpi
PRODUCT_AAPT_CONFIG := normal hdpi xhdpi
PRODUCT_CHARACTERISTICS := phone

PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.sensors@1.0-service \
    libmtk_symbols \
    libmtk_vendor

PRODUCT_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6739:root/fstab.mt6739

PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.device=a02 \
    ro.product.model=Galaxy\ A02 \
    ro.product.brand=samsung \
    ro.product.manufacturer=samsung \
    ro.build.product=a02 \
    ro.product.board=mt6739 \
    persist.sys.usb.config=mtp,adb

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=a02 \
    PRODUCT_NAME=lineage_a02

$(call inherit-product, vendor/samsung/a02/a02-vendor.mk)
