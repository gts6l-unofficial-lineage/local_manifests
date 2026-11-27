# Unofficial LineageOS 24.0 for Samsung Galaxy Tab S6 LTE (gts6l, SM-T865)

## Some Human-Written Words

Heya! This is LineageOS 24.0, with a modified version of the original 4.14 kernel.
I let Claude make this, with some input on design decisions and what existing work to base this on.

Please do not use this for anything important yet, this may lose all your data, randomly crash, or explode your tablet.
But in my experience, I did not have any issues watching videos or during web-browsing. (Although lots of small things don't work yet like microphone, sd-card, etc, see the tables below)

If you encounter any bugs or find anything wrong with this, please create an issue, so it can be fixed.

If you want to contribute and help to make this better, I'd be happy to hear from anyone.
(still need e.g. someone to help test a Wifi Version!)

## Everything below is AI generated.

An unofficial port. It is not made, endorsed or supported by the LineageOS project; please
do not report its bugs there. Beta quality: it runs as a daily driver on one tablet, but
expect bugs and keep a backup.

## Installing

Download `lineage-24.0-*-UNOFFICIAL-gts6l.zip`, `recovery.img` and `vbmeta.img` from the
[latest release](https://github.com/gts6l-unofficial-lineage/local_manifests/releases)
and check them against `SHA256SUMS`. (When building yourself, the three files are in
`out/target/product/gts6l/`.)

The bootloader must be unlocked and the tablet must run the T865XXU6DXE1 firmware. You
need `heimdall` and `adb`. **Installing wipes all data.**

1. Put the tablet in download mode: power it off, then hold Volume Up + Volume Down while
   plugging in the USB cable.
2. Flash the recovery and the disabled-verification vbmeta image:

       heimdall flash --RECOVERY recovery.img --VBMETA vbmeta.img --no-reboot

3. Boot straight into recovery: hold Power + Volume Down until the screen goes black, then
   immediately hold Power + Volume Up. If the stock system starts instead, it replaces the
   recovery and you have to repeat from step 1.
4. Choose *Factory reset* > *Format data/factory reset*.
5. Choose *Apply update* > *Apply from ADB* and sideload the build:

       adb sideload lineage-24.0-*-UNOFFICIAL-gts6l.zip

6. Optional: sideload a GApps package (MindTheGapps for Android 17, arm64) the same way
   before the first boot. The recovery asks whether to install it despite its signature;
   answer *Yes*.
7. Choose *Reboot system now*. The first boot takes a few minutes.

Updates are installed the same way (step 5 only); data and GApps are kept.

This repository is the entry point: the `repo` manifest, the build environment and the
install notes. The code lives in three other repositories:

| Repository | Path in the source tree | Contents |
|---|---|---|
| `android_device_samsung_gts6l` | `device/samsung/gts6l` | Tablet-specific configuration: display, speakers, thermal limits, fingerprint, S Pen |
| `android_device_samsung_sm8150-common` | `device/samsung/sm8150-common` | Configuration shared by Samsung Snapdragon 855 devices |
| `android_kernel_samsung_sm8150` | `kernel/samsung/sm8150` | Samsung 4.14 kernel, merged up to 4.14.357 |

Everything else is unmodified LineageOS 24.0; the port needs no platform patches.

## Status

Tested on one SM-T865 with the T865XXU6DXE1 bootloader and firmware.

| Area | State |
|---|---|
| Display, touch, S Pen, book cover | Working |
| Brightness | Working: stock curve (2 to 360 nits), auto-brightness, sunlight boost to 500 nits, reduced when the tablet gets hot as on stock |
| Fingerprint, PIN, encryption | Working |
| Wi-Fi (including WPA3), Bluetooth, GNSS | Working |
| Speakers | Working: all four, rotation aware, stock tuning |
| Cameras | Working; the ultra-wide camera is hidden in the LineageOS camera app |
| Video | Working: hardware decoding |
| Sensors | Working |
| Google apps | Working when sideloaded (kept across updates) |
| Microphones, call audio | Untested, probably not working |
| Mobile data, calls, SMS | Untested |
| USB-C audio | Not working |
| exFAT microSD cards | Not working (FAT32 works) |
| Double-tap to wake | Not working |
| VoLTE, VoWiFi | Not available |
| Widevine | L3 only |

Other known issues:

- Sounds are distorted during the setup wizard; they are normal afterwards.
- The camera takes a few seconds to open the first time after boot.
- The setup wizard can reject a new PIN as not matching; set the PIN in Settings instead.
- The stock audio calibration is not loaded.

## Building

    repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs
    git clone https://github.com/gts6l-unofficial-lineage/local_manifests -b lineage-24.0 .repo/local_manifests
    repo sync

The proprietary Android vendor files (HALs, libraries, firmware and configuration from
Samsung's vendor image) are not distributed; you extract them yourself.
`extract-stock-blobs.sh` downloads the stock firmware from Samsung's update servers (about
6 GB), unpacks its vendor image and runs the extraction scripts:

    ALLOW_OTHER_FIRMWARE=1 .repo/local_manifests/extract-stock-blobs.sh .

The kernel repository is a different matter: like Samsung's kernel source release it is
based on, it contains binary firmware for touch, key and charger controllers (`firmware/`)
and a few host tools (`tools/signclient.jar`, `tools/*.so`, `tools/mkdtimg`). They came
with Samsung's source package; this port has not established separate redistribution terms
for them.

It needs `samloader`, `unzip`, `tar`, `lz4`, `simg2img`, `debugfs` and `python3`. Pass an
already downloaded firmware package as second argument to skip the download. To extract
from an unpacked vendor image by hand, run `./extract-files.py /path/to/dump` in
`device/samsung/gts6l`.

The file lists were made from the vendor image of T865XXU6DXE1, and the releases are
built from it. Samsung's servers only offer the latest firmware, currently T865XXU6DXJ1,
in which 12 of the extracted files differ; a build from it is untested and still reports
the DXE1 fingerprint. The script therefore stops at any other firmware unless
`ALLOW_OTHER_FIRMWARE=1` is set, as in the command above. With a DXE1 package of your own,
pass it as second argument and leave the variable out.

Then build:

    source build/envsetup.sh
    lunch lineage_gts6l-cp2a-userdebug
    m bacon

A build made this way is signed with the public AOSP test keys, see *Security notes*.

### Rebuilding a release

`gts6l.xml` follows the LineageOS branches, so a build made later differs from a release.
For each release, `releases/` has a manifest that pins every project to the commit the
release was built from, and the SHA-256 list of the extracted proprietary files. To use
them, clone this repository somewhere outside `.repo` (not into `.repo/local_manifests`,
the pinned manifest is complete) and:

    repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs
    cp /path/to/local_manifests/releases/gts6l-24.0-20261127.xml .repo/manifests/
    repo init -m gts6l-24.0-20261127.xml
    repo sync
    /path/to/local_manifests/extract-stock-blobs.sh . /path/to/T865XXU6DXE1-firmware.zip
    (cd vendor/samsung && sha256sum -c --quiet /path/to/local_manifests/releases/gts6l-24.0-20261127.blobs.sha256)

The pinned manifest has not been tested with a fresh `repo sync`.

On NixOS, `nix/fhs.nix` provides the host environment:

    nix-build .repo/local_manifests/nix/fhs.nix -o fhs && ./fhs/bin/lineage-build

## Security notes

- **Signing.** Release builds from this project are signed with the port's own private
  keys (release certificate SHA-256
  `1A:23:19:AC:AA:56:DD:A2:5B:D0:0A:98:AA:E9:53:0C:92:C5:39:03:0F:33:90:84:A2:0D:74:A2:C7:A3:B0:9A`).
  A build you make from source is signed with the public AOSP test keys unless you set up
  your own, and anyone can sign an update that such a build accepts. Builds signed with
  different keys cannot be installed over each other without *Format data*. The APEX
  modules are signed with the test keys in both cases.
- **No verified boot.** The bootloader is unlocked and vbmeta is flashed with verification
  and hashtree checking disabled; the recovery image is signed with the public AVB test
  key because the build requires a key. Nothing checks the system, vendor or boot images
  at start-up, so someone with physical access can modify them. User data is still
  encrypted with your lock screen credential.
- **userdebug.** Builds are `userdebug`: `adb root` is available once USB debugging is
  enabled and the computer is authorised. Releases require that authorisation
  (`ro.adb.secure=1`).

## Licence

Files written for this port are under the Apache License 2.0 (`LICENSE`). The device
trees list the files under other terms in their `NOTICE`; the kernel is GPL-2.0.

## Updates

The Updater app reads `updates/gts6l.json` from this repository. The list is empty until
builds are published; updates can always be installed from recovery as described above.

## Layout notes

- Stock `SYSTEM` holds a dynamic `super` partition (system, system_ext, product, vendor,
  odm); stock `VENDOR`, `PRODUCT` and `ODM` are unused.
- The vendor image is built from the Android 11 stock blobs.
- The kernel is built without Samsung uH/RKP, as the LineageOS Samsung kernels are.
