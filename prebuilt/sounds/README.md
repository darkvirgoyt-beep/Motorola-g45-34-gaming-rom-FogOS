# VirgoX Elite GamingOS — Custom Sounds

## Sound Files Needed

Place your custom sound files here in the following structure:

### Notification Sounds
```
notifications/
├── virgox_notify.ogg          # Default notification
├── virgox_game_kill.ogg       # Gaming kill notification  
└── virgox_achievement.ogg     # Achievement unlocked
```

### Ringtones
```
ringtones/
├── virgox_ring_cyber.ogg      # Default ringtone
└── virgox_ring_pulse.ogg      # Gaming ringtone
```

### UI Sounds
```
ui/
├── virgox_lock.ogg            # Lock screen sound
├── virgox_unlock.ogg          # Unlock screen sound
└── virgox_charge.ogg          # Charging connected
```

### Alarm Sounds
```
alarms/
├── virgox_alarm_default.ogg   # Default alarm
```

## Format Requirements
- **Format:** OGG Vorbis (`.ogg`) — Android standard
- **Sample Rate:** 44100 Hz
- **Bit Rate:** 128-192 kbps
- **Channels:** Stereo
- **Duration:** Notifications 1-3 sec, Ringtones 15-30 sec, Alarms 10-30 sec

## How to Create
You can create custom sounds using:
- **Audacity** (free, open source)
- **FL Studio** / **GarageBand**
- **freesound.org** — royalty-free sound effects
- **pixabay.com/sound-effects** — free gaming sound effects

## Integration
Sounds are copied into the ROM via `virgox_packages.mk`:
```makefile
PRODUCT_COPY_FILES += \
    vendor/virgox/prebuilt/sounds/notifications/virgox_notify.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/VirgoXNotify.ogg
```
