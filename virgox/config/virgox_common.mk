# VirgoX Elite GamingOS - Common Configuration
# Inherited by virgox_fogos.mk

# Version
$(call inherit-product, vendor/virgox/virgox/config/version.mk)

# Packages
$(call inherit-product, vendor/virgox/virgox/config/virgox_packages.mk)

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += vendor/virgox/virgox/sepolicy

# System Properties
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    $(shell cat vendor/virgox/system_ext.prop)
