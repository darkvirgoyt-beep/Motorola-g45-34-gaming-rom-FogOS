# VirgoX-Elite-GamingOS-Rom product layer for Motorola fogos.
# Applied by scripts/build_source.sh after the audited device tree is synced.
$(call inherit-product, device/motorola/fogos/lineage_fogos.mk)

PRODUCT_NAME := virgox_fogos
PRODUCT_DEVICE := fogos
PRODUCT_MANUFACTURER := motorola
PRODUCT_BRAND := VirgoX
PRODUCT_MODEL := VirgoX Elite GamingOS
PRODUCT_GMS_CLIENTID_BASE := android-motorola

PRODUCT_SYSTEM_PROPERTIES += \
    ro.virgox.name=VirgoX-Elite-GamingOS-Rom \
    ro.virgox.edition=Elite-GamingOS \
    ro.virgox.maintainer=VIRGOYT707 \
    ro.virgox.device=fogos \
    ro.virgox.controller=com.fogos.control \
    ro.virgox.profile.default=balanced

PRODUCT_PACKAGES += FogOSPulseControl
BOARD_VENDOR_SEPOLICY_DIRS += device/motorola/fogos/virgox/sepolicy
