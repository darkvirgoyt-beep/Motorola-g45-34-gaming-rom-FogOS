# VirgoX Elite GamingOS — Custom Fonts

## Font Files

Place custom font files here to override Android system fonts.

### Recommended Gaming Fonts (Free & Open Source)
- **Rajdhani** — Clean, geometric, gaming-friendly (Google Fonts)
- **Orbitron** — Futuristic, techy display font
- **Exo 2** — Modern, clean with slight gaming edge
- **Play** — Clean sans-serif designed for UI readability
- **JetBrains Mono** — Excellent monospace for terminal/dev use

### File Structure
```
fonts/
├── VirgoXSans-Regular.ttf     # Default system font
├── VirgoXSans-Medium.ttf      # Medium weight
├── VirgoXSans-Bold.ttf        # Bold weight  
├── VirgoXMono-Regular.ttf     # Monospace font
└── fonts_customization.xml    # Font family definitions
```

### Example `fonts_customization.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<fonts-modification>
    <family customizationType="new-named-family" name="virgox-sans">
        <font weight="400" style="normal">VirgoXSans-Regular.ttf</font>
        <font weight="500" style="normal">VirgoXSans-Medium.ttf</font>
        <font weight="700" style="normal">VirgoXSans-Bold.ttf</font>
    </family>
</fonts-modification>
```

### Integration
Fonts are installed via product makefile:
```makefile
PRODUCT_COPY_FILES += \
    vendor/virgox/prebuilt/fonts/VirgoXSans-Regular.ttf:$(TARGET_COPY_OUT_PRODUCT)/fonts/VirgoXSans-Regular.ttf
```

### Download Sources
- [Google Fonts](https://fonts.google.com/) — Free, open source
- [Fontsource](https://fontsource.org/) — npm-installable fonts
- [Font Squirrel](https://www.fontsquirrel.com/) — Free commercial-use fonts
