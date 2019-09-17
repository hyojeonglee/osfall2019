# Project 0

* Assigned: 2019-09-18 Wed 18:30:00 KST
* **Due: 2018-09-24 Tue 13:00:00 KST**

## Introduction

This assignment will help you setup your kernel development environment. This project includes building kernel image from source code and flashing your device. After this project, the device will work with your kernel.

This is an individual project. You have to take a screenshot of terminal when you flash your device (screenshots for both starting and ending of flashing). Send the screenshot to the TA via email ([os-tas@dcslab.snu.ac.kr](mailto:os-tas%40dcslab.snu.ac.kr)) before the deadline.
The screenshot should look like:

![FlashingStart](/doc/assets/FlashingStart.png)
[At the beginning of flashing]

![FlashingEnd](/doc/assets/FlashingEnd.png)
[At the end of flashing]

## Your Device

The development device you will use throughout this semester is Raspberry Pi 3. The kit you received should contain the following:

* Raspberry Pi 3 development board and power supply
* SD card
* USB-to-UART cable

If something is missing or malfunctioning, contact TAs immediately via email ([os-tas@dcslab.snu.ac.kr](mailto:os-tas%40dcslab.snu.ac.kr)). You must return the kit when this course ends. So please take care when you use the device and try not to lose something.

**These items will be checked before you return them.**

## Development Environment

To build kernel images and flash the device on your PC, development environment must be prepared. There are number of ways to do this. Choose the most appropriate one for you.

**WARNING: Linux source tree has files whose names differ in case only. This means that you MUST use a _case sensitive_ filesystem when you work on your projects. Common case _insensitive_ filesystems include NTFS (Windows) and HFS+ (Mac); please avoid these when working with the source code. You do not have to worry about this if you stick to the setup guide we provided below.**

### Setup on Ubuntu

This is the most recommended way. You can install Ubuntu side-by-side with existing OS on your machine, or erase existing OS and install Ubuntu on it. (Learn more [#1](https://help.ubuntu.com/lts/installation-guide/amd64/index.html) [#2](https://help.ubuntu.com/community/WindowsDualBoot))

The following releases are supported:
* 16.04 LTS Xenial Xerus (and its point releases) (recommended)
* 14.04 LTS Trusty Tahr (and its point releases)
* 17.10.1 Artful Aardvark
* 18.04 LTS Bionic Beaver (unstable)

Then install the following packages: ccache, gcc-aarch64-linux-gnu, unrpm, pv
```bash
sudo apt-get install ccache gcc-aarch64-linux-gnu obs-build pv -y
```

### Setup on Windows PC

You can choose this way if your PC runs Windows.

[Learn more about setup procedure on Windows PC](/doc/SetupOnWindows.md)

### Setup on Mac

You can choose this way if you own a Mac.

[Learn more about setup procedure on Mac](/doc/SetupOnMac.md)

## Compiling the Kernel & Flashing the Device

Now it's time to actually build the kernel image and flash the device.

* If you use Virtual Machine, don't forget to execute commands in VM.

### Getting Kernel Source

You clone the kernel source using `git`. Execute the following command.
```bash
git clone https://github.com/hyojeonglee/tizen-5.0-rpi3.git
```

Or if you've [registered your ssh key to GitHub](https://help.github.com/articles/connecting-to-github-with-ssh/), you can execute the following command.
```bash
git clone git@github.com:hyojeonglee/tizen-5.0-rpi3.git
```

You don't have to type in GitHub username and password if you're cloning repository over ssh.

### Compiling the Kernel and Making images

Walk into the kernel source.
```bash
cd tizen-5.0-rpi3
```

And just type
```bash
./build-rpi3-arm64.sh
```
to compile the kernel.

Then, make boot images with the following shell script (you need sudo this time).
```bash
sudo ./scripts/mkbootimg_rpi3.sh
```
** You may turn off the automatic opening of mounted folders with `dconf-editor`.

Ensure that two new image files (`modules.img`, `boot.img`) are created.

### Flashing the Device

Before you flash your device, you should create an archive with two new images you just created. Run the following command:

```bash
tar -zcvf tizen-unified_20181024.1_iot-boot-arm64-rpi3.tar.gz boot.img modules.img
```

Make sure that you have two following archives:
*  `tizen-unified_20181024.1_iot-boot-arm64-rpi3.tar.gz` (the archive you just created)
*  `tizen-unified_20181024.1_iot-headless-2parts-armv7l-rpi3.tar.gz` (the default one which will not be changed throughout the projects)

Now, insert your SD card to the Linux computer and verify its device node ([how to verify device node](/doc/VerifyDeviceNode.md)).

Run the `flash-sdcard.sh` script with the device node:

```bash
sudo ./flash-sdcard.sh <SD card device node>
```

For example:
```bash
sudo ./flash-sdcard.sh /dev/sdb
```

Take a screenshot of the flashing process and submit it to TAs.

## Playing with the Device

You can connect your Raspberry Pi 3 device with your computer using USB-to-UART cable. Log in to your device as `root`, with password `tizen`.

You may test transferring files from your local Linux machine into Tizen ([how to move files into Tizen](/doc/MoveFilesToTizen.md)) and other command line prompt.

## We're Here to Help You

Any troubles? Discussions on [issue board](https://github.com/hyojeonglee/osfall2019/issues) is more than welcome. Remember, we are here to help you.

Start early, ask for help if needed, and most importantly, have fun!
