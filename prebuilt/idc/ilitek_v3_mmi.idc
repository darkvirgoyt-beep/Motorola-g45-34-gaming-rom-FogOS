# ==============================================================================
# VirgoX Esports Ultra-High 1000Hz Sampling Rate Input Device Configuration
# Target: Motorola Moto G45 5G / Moto G34 5G (fogos) — Snapdragon 695 5G
# Developer: Prince · VirgoYT (@darkvirgoyt-beep)
# ==============================================================================

# Core Device Type
touch.deviceType = touchScreen
touch.orientationAware = 1

# 1000Hz Esports Polling & Sampling Rate
touch.samplingRate = 1000
touch.reportRate = 1000

# High-Precision Gesture Handling
touch.gestureMode = spots

# Size Calibration: Default linear with zero bias
touch.size.calibration = default
touch.size.scale = 1.0
touch.size.bias = 0
touch.size.isSummed = 0

# Pressure Calibration: Instant touch registration with ultra-sensitive threshold
touch.pressure.calibration = amplitude
touch.pressure.scale = 0.005

# Orientation Calibration
touch.orientation.calibration = none

# Distance Calibration: Zero touch hover / direct surface registration
touch.distance.calibration = none

# Esports Raw Input: Bypass kernel/framework smoothing filters
# Level 0 = Raw unfiltered touch input (Zero delay, instant 1:1 crosshair aim)
touch.filter.level = 0

# Coverage & Precision
touch.coverage.calibration = box
