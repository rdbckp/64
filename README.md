# A02 64-bit Porting Local Manifest

## Status
- Kernel: 64-bit build ready (arch/arm64/configs exists)
- Vendor: Minimal 64-bit structure (Phase 1 boot testing)
- Goal: Boot GSI 64-bit system + 64-bit kernel with 64-bit vendor partition

## Quick Start: Pre-Build Setup

Before building, copy architecture-agnostic vendor files from your existing vendor_a02 (32-bit):

```bash
# Set path to your 32-bit vendor:
VENDOR_32BIT=../vendor_a02/vendor_a02/samsung/a02/proprietary

# Copy partition mount configs:
cp $VENDOR_32BIT/etc/fstab.* vendor/samsung/a02/proprietary/etc/

# Copy audio/media configs:
cp -r $VENDOR_32BIT/etc/audio vendor/samsung/a02/proprietary/etc/ 2>/dev/null || true
cp -r $VENDOR_32BIT/etc/media vendor/samsung/a02/proprietary/etc/ 2>/dev/null || true

# Copy firmware (modem/WiFi/BT):
cp -r $VENDOR_32BIT/firmware/* vendor/samsung/a02/proprietary/firmware/ 2>/dev/null || true

# Copy overlay (RRO):
cp -r $VENDOR_32BIT/overlay/* vendor/samsung/a02/proprietary/overlay/ 2>/dev/null || true

# Copy init script:
cp $VENDOR_32BIT/etc/init/hw/init.mt6739.rc vendor/samsung/a02/proprietary/etc/init/hw/ 2>/dev/null || true
```

## Key 64-bit Changes

### device/samsung/a02/BoardConfig.mk
- ✅ `TARGET_ARCH: arm → arm64`
- ✅ `TARGET_CPU_ABI: armeabi-v7a → arm64-v8a`
- ✅ `TARGET_USES_64_BIT_BINDER: false → true`
- ✅ `BOARD_KERNEL_IMAGE_NAME: zImage → Image.gz`
- ✅ `KERNEL_TARGET_ARCH: arm64` (NEW)
- ✅ `BOARD_VNDK_VERSION: 30` (NEW)

### vendor/samsung/a02/a02-vendor.mk
- ✅ `DEVICE_MANIFEST_FILE += vendor/samsung/a02/manifest.xml` (NEW)
- ✅ `PRODUCT_COPY_FILES` manifest to /vendor/etc/vintf/ (NEW)

### vendor/samsung/a02/manifest.xml
- ✅ NEW FILE: VINTF Treble manifest (critical for GSI compatibility)

## Build

```bash
source build/envsetup.sh
lunch lineage_a02-userdebug
make vendor -j8        # Build vendor 64-bit
make system -j8        # Build system (GSI 64-bit)
make boot -j8          # Build boot (kernel 64-bit)
```

## Expected First Boot

### ✅ Will Work:
- Kernel boots (64-bit)
- System/vendor mount
- `adb shell` accessible
- Properties load

### ❌ Will Error (Normal):
- GPU crash (gralloc 64-bit missing)
- Modem crash (RIL 64-bit missing)
- Audio crash (DSP 64-bit missing)

## Debug Boot

```bash
adb logcat > boot_log.log &
# Boot device, wait 15 sec, Ctrl+C
grep -i "error\|fail" boot_log.log
```

## Documentation Files

Included in repo:
- `A02_64BIT_PORTING_REVISED.md` - Detailed explanation
- `IMPLEMENTATION_CHECKLIST.txt` - Command reference
- `BoardConfig_64bit_REVISED.mk` - Device config template
- `a02-vendor_64bit_REVISED.mk` - Vendor makefile template
- `manifest_VINTF_TEMPLATE.xml` - VINTF template

## Next Phase

After successful boot, refine:
1. Add GPU HAL blob (64-bit gralloc)
2. Add modem/RIL (64-bit)
3. Add audio HAL (64-bit)
4. Optimize SELinux policies