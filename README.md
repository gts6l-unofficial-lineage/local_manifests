# LineageOS 24.0 for the Samsung Galaxy Tab S6 LTE (gts6l, SM-T865)

Unofficial port, beta quality: it runs as a daily driver on one tablet, but expect bugs
and keep a backup. This repository is the entry point: the `repo` manifest, the build
environment and the install notes. The code lives in three other repositories:

| Repository | Path in the source tree | Contents |
|---|---|---|
| `android_device_samsung_gts6l` | `device/samsung/gts6l` | Tablet-specific configuration: display, speakers, fingerprint, S Pen |
| `android_device_samsung_sm8150-common` | `device/samsung/sm8150-common` | Configuration shared by Samsung Snapdragon 855 devices |
| `android_kernel_samsung_sm8150` | `kernel/samsung/sm8150` | Samsung 4.14 kernel, merged up to 4.14.357 |

Everything else is unmodified LineageOS 24.0; the port needs no platform patches.

## Status

Tested on an SM-T865 with the T865XXU6DXE1 bootloader and firmware.

Working: display, touch, S Pen, book cover, fingerprint, encryption, Wi-Fi, Bluetooth,
sensors, cameras, audio (four speakers, rotation aware, stock tuning), GNSS, Widevine,
GApps through `addon.d`.

Not yet verified: WPA3, mobile data and calls.

Known issues: see the issue tracker of this repository.

## Building

    repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs
    git clone https://github.com/GITHUB_ORG/local_manifests -b lineage-24.0 .repo/local_manifests
    repo sync

The proprietary files are not distributed. `extract-stock-blobs.sh` downloads the stock
firmware from Samsung's update servers (about 6 GB), unpacks its vendor image and runs
the extraction scripts:

    .repo/local_manifests/extract-stock-blobs.sh .

It needs `samloader`, `unzip`, `tar`, `lz4`, `simg2img`, `debugfs` and `python3`. Pass an
already downloaded firmware package as second argument to skip the download. To extract
from an unpacked vendor image by hand, run `./extract-files.py /path/to/dump` in
`device/samsung/gts6l`.

Samsung's servers only offer the latest firmware, currently T865XXU6DXJ1. The file lists
were made from T865XXU6DXE1; 12 of the 474 files differ between the two.

Then build:

    source build/envsetup.sh
    lunch lineage_gts6l-cp2a-userdebug
    m bacon

On NixOS, `nix/fhs.nix` provides the host environment:

    nix-build nix/fhs.nix -o fhs && ./fhs/bin/lineage-build

## Installing

The bootloader must be unlocked and the tablet must run the T865XXU6DXE1 firmware.
Installing wipes all data.

1. Put the tablet in download mode and flash the recovery and the disabled-verification
   vbmeta image from the build output:

       heimdall flash --RECOVERY recovery.img --VBMETA vbmeta.img --no-reboot

2. Boot into recovery (hold Power + Volume Up while it restarts), choose
   *Factory reset* > *Format data*.
3. Choose *Apply update* > *Apply from ADB* and sideload the build:

       adb sideload lineage-24.0-*-UNOFFICIAL-gts6l.zip

4. Optional: sideload a GApps package before the first boot.

Updates are installed the same way (step 3 only); data and GApps are kept.

## Layout notes

- Stock `SYSTEM` holds a dynamic `super` partition (system, system_ext, product, vendor,
  odm); stock `VENDOR`, `PRODUCT` and `ODM` are unused.
- The vendor image is built from the Android 11 stock blobs.
- The kernel is built without Samsung uH/RKP, as the LineageOS Samsung kernels are.
