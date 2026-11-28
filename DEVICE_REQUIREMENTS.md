# LineageOS device support requirements: checklist for gts6l

This port is unofficial. The list below measures it against the requirements LineageOS
sets for its official devices, to show what is missing and what has never been tested.

Source: [LineageOS Device Support Requirements](https://github.com/LineageOS/charter/blob/main/device-support-requirements.md)
(as of 2026-11-27, licensed CC-BY-3.0). The requirement texts are shortened; the original
is authoritative. MUST / SHOULD / MAY are used as in that document.

State: the tree after `gts6l-24.0-20261127`, checked on one SM-T865 (T865XXU6DXE1).

- `[x]` met and checked on the tablet or in the tree
- `[ ]` not met, or not tested; the note says which
- **n/a** the tablet does not have the hardware, or the rule cannot apply to an unofficial port

## Open MUST items

| Requirement | State |
|---|---|
| In-call audio | Untested (no SIM); microphones record, but without stock echo cancellation |
| USB-C audio output | Fix in the tree, untested |
| Mobile data, calls, emergency calls | Untested (no SIM) |
| Wi-Fi and Bluetooth MAC address as on stock | Not compared with stock |
| Wi-Fi hotspot | Not working |
| USB tethering, MTP | Untested |
| Hardware video encoding | Untested |
| Updater app | Points at this port's list; an update through it is untested |
| Firmware assert | Missing: the build installs on any firmware |
| `lineage.dependencies` | Names repositories that are not in the LineageOS organisation |
| Copyright headers | Port-written files name their author, not The LineageOS Project |

## Device ownership

- [x] MUST own the device.

## Hardware support

### Audio

- [x] MUST play media audio. Four speakers, rotation aware.
- [ ] Tablets capable of calls MUST support in-call and speaker audio. **Untested** (no SIM); the microphones record.
- [ ] SHOULD support additional audio configuration (echo cancellation, extra microphones). **Not met**: the stock Qualcomm calibration (ACDB) is not loaded; it is made for Samsung's audio HAL and broke playback with the open-source one.
- [ ] MUST support the other audio outputs of stock:
  - [x] Bluetooth: A2DP checked with LDAC (fixed after `20261127`).
  - [ ] USB-C: **fix in the tree, untested**.
- **n/a** FM radio: not present.

### RIL

- [ ] MUST support calls and data. **Untested** (no SIM); the modem services start.
- [ ] MUST support emergency calls with a SIM. **Untested**.
- [ ] SHOULD support emergency calls without a SIM. **Untested**.

### Encryption

- [x] MUST support hardware-backed encryption if stock did. File-based encryption with the Samsung keymaster 4.0 (TEE).
- [x] SHOULD encrypt by default.
- [x] MUST support software encryption.

### Wi-Fi

- [x] MUST support Wi-Fi. Including WPA3.
- [ ] MUST report the same MAC address as stock. **Not compared.**
- [ ] MUST support Wi-Fi tethering. **Not working** as reported by the owner; the access point starts, the cause is not found yet.

### USB

- [ ] MUST support file access via MTP. **Untested.**
- [ ] MUST support USB tethering if stock did. **Untested.**

### GPS

- [x] MUST support GPS.

### Bluetooth

- [x] MUST support Bluetooth. Pairing and audio checked; profiles were disabled up to `20261127`.
- [ ] MUST report the same MAC address as stock. **Not compared.**
- [ ] SHOULD support Bluetooth tethering. **Untested.**
- [ ] SHOULD support the aptX variants stock supports (aptX, aptX HD, aptX Adaptive, aptX TWS+). **Not met**: with a headset that supports them, only LDAC and SBC were offered.

### Camera

- [x] MUST support front and rear camera.
- [ ] SHOULD support all rear cameras. Ultra-wide: **fix in the tree, untested** (it was hidden in the camera app).
- **n/a** Multiple front cameras: one.

### Video recording

- [x] MUST support video recording, front and rear. Picture checked; sound not (see microphones).

### Codecs

- [x] MUST support hardware decoding of the non-proprietary codecs of stock. Playback checked; not every codec individually.
- [ ] MUST support hardware encoding. **Untested.**

### Display

- [x] MUST use the stock resolution (1600x2560).
- [x] SHOULD use the stock density (360).
- [ ] SHOULD support USB display output (DisplayPort over USB-C). **Untested.**
- [ ] SHOULD support HDR10 playback. **Untested.**

### NFC, IR

- **n/a** Not present.

### Fingerprint sensor

- [x] MUST support the fingerprint sensor (optical, under the display; an artifact shows on screen next to the sensor, and lighting it raises the brightness of the whole panel).

### SD card

- [x] MUST support SD cards. FAT32 checked. One card rejected all writes at every bus speed; most likely the card.
- [ ] SHOULD support adoptable storage. **Untested.**

### Sensors

- [x] Accelerometer.
- [x] Gyroscope.
- **n/a** Proximity: not present.
- [x] Light sensor (automatic brightness checked).
- [ ] SHOULD support the other sensors of stock. Magnetometer, hall sensor (book cover) and the sensor hub types are listed; **not checked one by one**.

### Accessories

- [x] SHOULD support proprietary accessories: S Pen and book cover work.
- [ ] S Pen Bluetooth remote ("air actions"), keyboard cover, DeX. **Untested.**

### Hardware deviations

- [ ] MUST be documented on the Wiki. There is no Wiki page; the README lists them.

## Software support

### Device tree structure

- [ ] MUST use a codename not used by an official device. `gts6l`: **not verified** against the LineageOS device list.
- [x] MUST have a `lineage_gts6l` makefile.
- [ ] MUST have a `lineage.dependencies` that works with `breakfast` and names only LineageOS repositories. **Not met**: the common tree and the kernel are not in the LineageOS organisation; the manifest in this repository replaces it.

### Build type

- [x] MUST be `userdebug`.

### Kernel

- [x] MUST NOT ship a prebuilt kernel. Built from source (4.14.357).
- [x] MUST NOT implement wake gestures without hardware support. Double-tap uses the touch controller's own function (`aot_enable`).
- [x] MUST NOT force fast charging over USB.
- [x] CPU and GPU clocks and voltages as on stock. Not changed by this port.
- [x] MUST NOT add register manipulation (sound control and the like).
- [x] MUST NOT add a custom KSM driver.
- [x] Only allowed governors: conservative, ondemand, userspace, powersave, performance, schedutil.
- [x] Only allowed I/O schedulers: noop, deadline, cfq.
- [x] Only OEM or SoC vendor hotplug drivers.

### SELinux

- [x] MUST be enforcing.

### Verity

- [x] MUST disable verity on the system image for userdebug builds.
- [ ] SHOULD support verity on the vendor image. **Not met**: vbmeta disables verification for all partitions.

### Updater

- [ ] MUST support updates through the Updater app and the documented recovery. Recovery sideload: checked. Updater app: **untested**, its list is still empty.

### FRP

- [ ] SHOULD support factory reset protection with Google apps. **Untested.**

### Play Integrity

- [x] MUST NOT alter Play Integrity responses.

### Binder, su, non-PIE

- [x] 64-bit binder.
- [x] No `su`.
- [x] No non-PIE executables among the proprietary files.

### Proprietary files extraction

- [x] MUST have a working extraction script. Checked from the stock firmware dump: a fresh run reproduces the files byte for byte.
- [ ] ... that also works from a running LineageOS installation. **Untested.**
- [x] SHOULD use `tools/extract-utils`.
- [x] MUST take the files from the same device's public firmware (T865XXU6DXE1).
- [x] MUST note the source of un-pinned files in the lists.
- [x] MUST NOT include Megvii or SenseTime blobs. None found by file name.

### CVE

- [ ] MUST have patches for high-profile vulnerabilities; SHOULD receive regular kernel patches. The kernel is merged up to 4.14.357 (OpenELA); **no separate audit** of individual CVEs.

### Firmware

- [ ] MUST assert on known working firmware. **Not met**: nothing checks the bootloader or modem version at install; the README states the requirement (T865XXU6DXE1).

### exFAT

- [x] MAY support exFAT with a kernel implementation (kernel older than 5.7, stock supports exFAT). Samsung's sdFAT driver. **Not working** in `20261127`; fix in the tree, untested with an exFAT card.

### Additional features

- [ ] SHOULD support LiveDisplay colour adjustment in the kernel. **Not met**: no LiveDisplay HAL.

### Software deviations

- [ ] Deviations from other LineageOS devices MUST be approved and documented. Deliberate deviations of this unofficial port: no LineageOS statistics (setup wizard page and Trust entry removed), Updater pointed at this port's own list, "LineageOS (unofficial)" in the setup wizard.
- [x] MUST ship Jelly or another LineageOS browser.

### Vendor images

- [x] MUST NOT require a modified prebuilt vendor image. The vendor image is built.
- [ ] SHOULD verify basic hardware functions with an AOSP GSI. **Not done** on this vendor image.

## Quality of life

- [x] Commit authorship: imported and backported kernel commits keep their original authors.
- [ ] Copyrights: original contributions MUST be "(C) The LineageOS Project". **Not met on purpose**: files written for this port name their actual author; upstream copyrights are kept.
- [x] Workflow: no force pushes since publication.
- **n/a** GitLab issues: bugs go to this repository's issue tracker.
- [x] Licensing: kernel GPL-2.0, Android parts Apache-2.0; exceptions are listed in the `NOTICE` files.
- [ ] Wiki: none. Install instructions and deviations are in the README.
- [ ] Stability: no "screen of death" seen; battery drain **not measured**.
- [x] LineageOS Recovery is built, shipped and used for installation.
- [x] Addon packages install through the recovery (MindTheGapps checked).
