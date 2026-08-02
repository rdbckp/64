# Samsung Galaxy A02 → 64-bit Porting Guide (Revised)

**Status:** Dari 32-bit (ARM) → 64-bit (arm64)  
**Kernel:** Sudah build (`a022f_kernel` dengan `arch/arm64/configs`)  
**Next:** Vendor tree 64-bit minimal buat boot GSI 64-bit

---

## Struktur Existing Project Lo

```
a02_local_manifest/
├── device/samsung/a02/
│   ├── BoardConfig.mk              ← Architecture definition (PERLU EDIT)
│   ├── device.mk
│   ├── lineage_a02.mk
│   ├── AndroidProducts.mk
│   ├── system.prop
│   ├── rootdir/etc/fstab.mt6739    ← Partition mount (AMAN, copy aja)
│   └── overlay/                    ← RRO overlay (AMAN, copy aja)
│
├── kernel/samsung/a02/
│   ├── Android.mk
│   ├── Makefile
│   └── README.md
│
├── vendor/samsung/a02/
│   ├── BoardConfigVendor.mk        ← Vendor config (PERLU EDIT)
│   ├── a02-vendor.mk               ← Main vendor makefile (PERLU EDIT)
│   ├── vendor.prop                 ← Vendor properties (AMAN)
│   ├── configs/board.mk            ← Board specific (review)
│   └── Android.mk
│
└── local_manifest.xml              ← Repo manifest (SKIP, tetap 32-bit repos)
```

---

## Critical Changes untuk 64-bit

### 1. device/BoardConfig.mk

**DARI (32-bit):**
```makefile
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_USES_64_BIT_BINDER := false
TARGET_KERNEL_CONFIG := a02_defconfig
BOARD_KERNEL_IMAGE_NAME := zImage
```

**MENJADI (64-bit):**
```makefile
# Architecture — 64-bit only (atau bisa tambah 32-bit compat kemudian)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
# TARGET_2ND_ARCH := arm           # (optional, kalau mau 32-bit compat nanti)
# TARGET_2ND_ARCH_VARIANT := armv7-a-neon
# TARGET_2ND_CPU_ABI := armeabi-v7a

TARGET_USES_64_BIT_BINDER := true

# Kernel — tetap sama, cuma kernel image-nya sekarang dari build arm64
TARGET_KERNEL_CONFIG := a02_defconfig  # Atau a02_64_defconfig kalau ada
KERNEL_TARGET_ARCH := arm64            # TAMBAHAN: Force kernel build ke arm64
TARGET_KERNEL_SOURCE := kernel/samsung/a02
BOARD_KERNEL_IMAGE_NAME := Image.gz    # arm64 biasanya Image.gz bukan zImage

# Boot offsets tetap sama (hardware gak berubah):
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_RAMDISK_OFFSET := 0x05000000
BOARD_TAGS_OFFSET := 0x0e000000

# Recovery/Bootloader tetap (gak ada perubahan):
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_USES_RECOVERY_AS_BOOT := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6739

# Partitions — HARUS SAMA EXACTLY (hardware layout gak berubah):
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2147483648
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912
BOARD_USERDATAIMAGE_PARTITION_SIZE := 11534336000
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_CACHEIMAGE_PARTITION_SIZE := 536870912

# VNDK version (Android 11 = VNDK 30):
BOARD_VNDK_VERSION := 30

# SELinux — tetap permissive dulu buat debug:
BOARD_SEPOLICY_TEE_FLAVOR := msm
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Device-specific:
USE_CAMERA_STUB := true

# Include vendor config:
-include vendor/samsung/a02/BoardConfigVendor.mk
```

**Key edits:**
- ✅ `TARGET_ARCH := arm64` 
- ✅ `TARGET_CPU_ABI := arm64-v8a`
- ✅ `TARGET_USES_64_BIT_BINDER := true`
- ✅ `BOARD_KERNEL_IMAGE_NAME := Image.gz` (arm64 format)
- ✅ `BOARD_VNDK_VERSION := 30` (TAMBAH)
- ✅ `KERNEL_TARGET_ARCH := arm64` (TAMBAH, kalau kernel build system lo support)

---

### 2. vendor/BoardConfigVendor.mk

**DARI:**
```makefile
DEVICE_VENDOR_RELEASE_CONFIG_WILDCARD := vendor/samsung/a02/configs/*.xml
TARGET_VENDOR_PROP += vendor/samsung/a02/vendor.prop
BOARD_VENDOR_SEPOLICY_DIRS += vendor/samsung/a02/sepolicy
```

**MENJADI:**
```makefile
# Vendor release config (tetap sama):
DEVICE_VENDOR_RELEASE_CONFIG_WILDCARD := vendor/samsung/a02/configs/*.xml

# Vendor properties (tetap):
TARGET_VENDOR_PROP += vendor/samsung/a02/vendor.prop

# Vendor SELinux (tetap):
BOARD_VENDOR_SEPOLICY_DIRS += vendor/samsung/a02/sepolicy

# TAMBAHAN 64-bit specific:
# Vendor image filesystem:
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

# Binder version (64-bit):
TARGET_USES_64_BIT_BINDER := true

# Dynamic partition (kalau lo support — optional):
# BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
# BOARD_SUPER_PARTITION_SIZE := ...
```

Honestly, file ini bisa tetap apa adanya — paling tinggal ensure `TARGET_USES_64_BIT_BINDER := true` di sini atau device BoardConfig.

---

### 3. vendor/a02-vendor.mk

**DARI:**
```makefile
$(call inherit-product, vendor/samsung/a02/configs/board.mk)

PRODUCT_PACKAGES += \
    libmtk_symbols \
    libmtk_vendor

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.device=a02 \
    ro.vendor.model=Galaxy\ A02 \
    ro.vendor.product.device=a02 \
    ro.vendor.product.model=Galaxy\ A02
```

**MENJADI (tetap sama dulu, nanti add 64-bit specific HAL):**
```makefile
$(call inherit-product, vendor/samsung/a02/configs/board.mk)

# Minimal vendor packages (libmtk_symbols/libmtk_vendor bisa skip/dummy dulu)
PRODUCT_PACKAGES += \
    libmtk_symbols \
    libmtk_vendor

# Vendor properties (tetap):
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.device=a02 \
    ro.vendor.model=Galaxy\ A02 \
    ro.vendor.product.device=a02 \
    ro.vendor.product.model=Galaxy\ A02 \
    ro.vendor.extension_library=/vendor/lib64/libqti-perfd-client.so

# TAMBAHAN: VINTF manifest untuk Treble compliance (64-bit)
DEVICE_MANIFEST_FILE += vendor/samsung/a02/manifest.xml

# TAMBAHAN: Native bridge (kalau perlu arm32 compat kemudian):
# PRODUCT_PACKAGES += \
#     libnative_bridge \
#     libnative_bridge_jni \
#     libhoudini \
#     libhoudini32 \
#     libhoudini64
```

**Keterangan:**
- Bisa tetap minimal dulu, skip libmtk_symbols/libmtk_vendor (ini 32-bit)
- VINTF manifest CRITICAL buat Treble (64-bit GSI). Kita perlu buat file ini (lihat step 4)

---

### 4. vendor/manifest.xml (CRITICAL — BUAT FILE BARU)

Buat file baru: `vendor/samsung/a02/manifest.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest version="2.0" type="vendor" target-level="30">
  <!-- 
    VINTF Manifest untuk A02 64-bit vendor partition
    target-level="30" = Android 11 VNDK 30
    Ini interface yang di-declare di vendor layer
  -->

  <!-- Kernel HAL (bukan di-declare, implicit di kernel) -->
  <!-- <hal format="hidl">
    <name>android.hardware.audio</name> ...
    ^^ Ini gak di-declare di manifest, cuma di kernel dts
  -->

  <!-- Display HAL (placeholder, actual blob TBD) -->
  <hal format="hidl">
    <name>android.hardware.graphics.allocator</name>
    <transport>hwbinder</transport>
    <version>3.0</version>
    <interface>
      <name>IAllocator</name>
      <instance>default</instance>
    </interface>
  </hal>

  <hal format="hidl">
    <name>android.hardware.graphics.composer</name>
    <transport>hwbinder</transport>
    <version>2.1</version>
    <interface>
      <name>IComposer</name>
      <instance>default</instance>
    </interface>
  </hal>

  <!-- Power HAL (minimal, dapat dari VNDK) -->
  <hal format="hidl">
    <name>android.hardware.power</name>
    <transport>hwbinder</transport>
    <version>1.2</version>
    <interface>
      <name>IPower</name>
      <instance>default</instance>
    </interface>
  </hal>

  <!-- Lights HAL (minimal) -->
  <hal format="hidl">
    <name>android.hardware.lights</name>
    <transport>hwbinder</transport>
    <version>2.0</version>
    <interface>
      <name>ILight</name>
      <instance>default</instance>
    </interface>
  </hal>

  <!-- Vibrator HAL -->
  <hal format="hidl">
    <name>android.hardware.vibrator</name>
    <transport>hwbinder</transport>
    <version>1.3</version>
    <interface>
      <name>IVibrator</name>
      <instance>default</instance>
    </interface>
  </hal>

  <!-- RIL (modem driver, TBD) -->
  <hal format="hidl">
    <name>android.hardware.radio</name>
    <transport>hwbinder</transport>
    <version>1.5</version>
    <interface>
      <name>IRadio</name>
      <instance>slot1</instance>
    </interface>
    <interface>
      <name>ISap</name>
      <instance>slot1</instance>
    </interface>
  </hal>

  <!-- WiFi (TBD) -->
  <hal format="hidl">
    <name>android.hardware.wifi</name>
    <transport>hwbinder</transport>
    <version>1.4</version>
    <interface>
      <name>IWifi</name>
      <instance>default</instance>
    </interface>
  </hal>

  <!-- Bluetooth (TBD) -->
  <hal format="hidl">
    <name>android.hardware.bluetooth</name>
    <transport>hwbinder</transport>
    <version>1.1</version>
    <interface>
      <name>IBluetoothHci</name>
      <instance>default</instance>
    </interface>
  </hal>

  <!-- Thermal (optional) -->
  <hal format="hidl">
    <name>android.hardware.thermal</name>
    <transport>hwbinder</transport>
    <version>2.0</version>
    <interface>
      <name>IThermal</name>
      <instance>default</instance>
    </interface>
  </hal>

  <!-- SELinux version (MUST match Android 11) -->
  <sepolicy>
    <version>30.0</version>
  </sepolicy>
</manifest>
```

**Keterangan:**
- Declare HAL yang diharapkan ada di vendor partition
- `target-level="30"` = Android 11 / VNDK 30
- Actual `.so` blob untuk HAL bisa dummy/missing dulu, fokus dulu ke boot

---

## Step-by-Step Implementation

### Phase 1: Setup Struktur Folder (10 menit)

```bash
# Di dalam project root (AOSP/Android build tree):
cd vendor/samsung/a02

# Ensure struktur yang ada:
ls -la                 # Lihat: Android.mk, a02-vendor.mk, BoardConfigVendor.mk, vendor.prop

# Buat folder yang kurang:
mkdir -p proprietary/lib64/hw
mkdir -p proprietary/etc/init/hw
mkdir -p proprietary/etc/vintf

# (Folder firmware, overlay, etc udah ada dari 32-bit, tinggal reuse)
```

### Phase 2: Edit BoardConfig.mk (Device Level)

```bash
# Edit device/samsung/a02/BoardConfig.mk
# Ganti TARGET_ARCH dari arm → arm64
# Ganti TARGET_USES_64_BIT_BINDER dari false → true
# Ganti BOARD_KERNEL_IMAGE_NAME dari zImage → Image.gz
# TAMBAH: BOARD_VNDK_VERSION := 30

# Verify:
grep -i "TARGET_ARCH\|BINDER\|KERNEL_IMAGE\|VNDK" device/samsung/a02/BoardConfig.mk
```

### Phase 3: Create VINTF Manifest

```bash
# Copy template di atas ke:
vendor/samsung/a02/manifest.xml

# Verify di a02-vendor.mk include-nya:
grep -i "DEVICE_MANIFEST_FILE" vendor/samsung/a02/a02-vendor.mk
# Kalau gak ada, add line:
# DEVICE_MANIFEST_FILE += vendor/samsung/a02/manifest.xml
```

### Phase 4: Update a02-vendor.mk

```bash
# Edit vendor/samsung/a02/a02-vendor.mk
# Ensure:
# - DEVICE_MANIFEST_FILE += vendor/samsung/a02/manifest.xml
# - TARGET_USES_64_BIT_BINDER := true (atau udah di device BoardConfig)
# - Skip/comment libmtk_symbols/libmtk_vendor kalau 32-bit only
```

### Phase 5: Copy Arch-Agnostic Files dari Vendor 32-bit

```bash
# File dari vendor_a02 (32-bit) yang AMAN di-copy:
# (asumsi lo punya clone/copy dari vendor_a02)

VENDOR_32BIT=/path/to/vendor_a02/vendor_a02/samsung/a02/proprietary

# Copy fstab (partition mount gak depend arch):
cp $VENDOR_32BIT/etc/fstab.* proprietary/etc/

# Copy audio/media config XML (arch-agnostic):
cp -r $VENDOR_32BIT/etc/audio proprietary/etc/
cp -r $VENDOR_32BIT/etc/media proprietary/etc/

# Copy firmware (modem/wifi/bt, arch-agnostic):
cp -r $VENDOR_32BIT/firmware/* proprietary/firmware/

# Copy overlay (RRO, arch-agnostic):
cp -r $VENDOR_32BIT/overlay/* proprietary/overlay/ 2>/dev/null || true

# Copy init script (review, mostly safe):
cp $VENDOR_32BIT/etc/init/hw/init.mt6739.rc proprietary/etc/init/hw/
```

### Phase 6: Build Test

```bash
# Set build environment:
source build/envsetup.sh

# List available targets (lo biasanya ada lineage_a02 atau custom target):
lunch

# Biasanya jadi: lineage_a02-userdebug (untuk 32-bit)
# Buat 64-bit, mungkin perlu target baru atau variant, tapi coba dulu:
lunch lineage_a02-userdebug

# Build vendor partition:
make vendorimage -j8

# Atau full build kalau GSI 64-bit lo udah siap:
make system -j8  # System GSI 64-bit
make vendor -j8  # Vendor 64-bit (baru)
make boot -j8    # Boot (kernel 64-bit)
```

---

## Expected Behavior

### ✅ Akan Berhasil:
- Boot kernel 64-bit
- Mount vendor partition
- System mount
- Binder IPC work (64-bit)
- `adb shell` accessible
- Properties read dari vendor.prop

### ❌ Akan Error (Expected, Refinement Phase 2):
- Display/GPU (gralloc missing)
- Camera system crash (ISP blob missing)
- Audio playback (DSP driver missing)
- Touchscreen (hardware-specific driver)
- RIL crash (modem driver missing)

**Ini NORMAL.** Goal adalah boot + adb work. Error logs akan guide refinement kemudian.

---

## Debug: Capture Logcat saat First Boot

```bash
# Sebelum flash, siapkan:
adb logcat > logcat_64bit_boot.log &

# Flash boot.img + vendor.img + system.img ke device

# Monitor 10-15 detik, tekan Ctrl+C adb logcat

# Cek error:
grep -i "error\|failed\|gralloc\|modem" logcat_64bit_boot.log

# Share log buat diagnosis next phase
```

---

## File Checklist

**Harus di-edit:**
- [ ] `device/samsung/a02/BoardConfig.mk` — 64-bit arch + VNDK 30
- [ ] `vendor/samsung/a02/a02-vendor.mk` — add DEVICE_MANIFEST_FILE
- [ ] `vendor/samsung/a02/BoardConfigVendor.mk` — review, minimal edits

**Harus di-buat:**
- [ ] `vendor/samsung/a02/manifest.xml` — VINTF Treble manifest

**Bisa di-copy dari vendor_a02 (32-bit):**
- [ ] `proprietary/etc/fstab.*`
- [ ] `proprietary/etc/audio/*`
- [ ] `proprietary/etc/media/*`
- [ ] `proprietary/firmware/*`
- [ ] `proprietary/overlay/*`
- [ ] `proprietary/etc/init/hw/init.mt6739.rc`

**Keep as-is / Review:**
- [ ] `vendor/vendor.prop` — aman tetap
- [ ] `device/rootdir/etc/fstab.mt6739` — aman
- [ ] Overlay yang di-device tree — aman

---

## Next Steps After First Boot

1. **Capture logcat** → identify missing HAL / crash reason
2. **If GPU crash:** Cari gralloc 64-bit (dari donor device, atau implement dummy)
3. **If modem crash:** Implement minimal RIL stub, atau cari modem blob 64-bit
4. **If audio crash:** Implement audio HAL stub atau cari dari donor
5. **Iterative refinement** — add HAL satu per satu sesuai logcat feedback

---

**Good luck bro! Ini solid foundation, tinggal eksekusi.**
