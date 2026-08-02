$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, device/samsung/a02/device.mk)
$(call inherit-product, vendor/samsung/a02/a02-vendor.mk)

PRODUCT_NAME := lineage_a02
PRODUCT_DEVICE := a02
PRODUCT_BRAND := samsung
PRODUCT_MODEL := Galaxy A02
PRODUCT_MANUFACTURER := samsung
