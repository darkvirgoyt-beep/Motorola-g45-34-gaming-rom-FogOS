# VirgoX Elite GamingOS - Custom Packages

# Gaming Profile Controller
PRODUCT_PACKAGES += \
    FogOSPulseControl

# RRO Overlays
PRODUCT_PACKAGES += \
    VirgoXFrameworkOverlay \
    VirgoXSystemUIOverlay

# Prebuilt Boot Animation
PRODUCT_COPY_FILES += \
    vendor/virgox/prebuilt/bootanimation/bootanimation.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip

# Gaming Scripts
PRODUCT_COPY_FILES += \
    vendor/virgox/patches/fogos_ram_optimizer.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/fogos_ram_optimizer.sh \
    vendor/virgox/patches/fogos_game_network.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/fogos_game_network.sh

# Sysconfig
PRODUCT_COPY_FILES += \
    vendor/virgox/sysconfig/gaming_power_whitelist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/gaming_power_whitelist.xml

# Gaming Profiles
PRODUCT_COPY_FILES += \
    vendor/virgox/virgox/gaming_profiles.json:$(TARGET_COPY_OUT_SYSTEM)/etc/virgox/gaming_profiles.json

# Game Mode Configuration
PRODUCT_COPY_FILES += \
    vendor/virgox/patches/game_mode_config.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/game_mode_config.xml
