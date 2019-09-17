# Setup on Mac

## Installing the Requirements

### Oracle VM VirtualBox and Extension Pack

* Download Oracle VM VirtualBox and Extension Pack from [here](https://www.virtualbox.org/wiki/Downloads).
* Install VirtualBox.

![VirtualBoxPreferences](/doc/assets/Win01VirtualBoxPreferences.PNG)
![VirtualBoxInstallExtension](/doc/assets/Win02VirtualBoxInstallExtension.PNG)

* Install VirtualBox Extension Pack.

## Setting up Virtual Machine

You need to create a new virtual machine where you can compile kernel soruce and flash the device with your kernel images.

### Creating a Virtual Machine

On VirtualBox, create a new virtual machine instance.

* You need to allocate at least one virtual CPU core and 1GB of RAM.
    * Adding up more resources may help speeding up the build process.
* You need at least 3GB free space after installing Ubuntu on your VM.
    * Creating virtual hard drive with more than 12GB space is recommended if you cannot estimate free space after installing Ubuntu.

### Installing Ubuntu

First, download Ubuntu release from [ubuntu.com](https://www.ubuntu.com/download) or [release archive](http://kr.archive.ubuntu.com/ubuntu-releases).

We recommend you to download Ubuntu 16.04 LTS or its point releases.

* [ubuntu-16.04.4-desktop-amd64.iso](http://kr.archive.ubuntu.com/ubuntu-releases/xenial/ubuntu-16.04.4-desktop-amd64.iso)
* [ubuntu-16.04.4-server-amd64.iso](http://kr.archive.ubuntu.com/ubuntu-releases/xenial/ubuntu-16.04.4-server-amd64.iso) (Server edition may provide better performance, but GUI is not enabled out-of-the-box and it's a little bit harder to install.)

Start your VM and insert the ISO image into the virtual disk drive. Follow the on-screen instructions to install Ubuntu.

### How to mount SD cards within VirtualBox on Mac

See the following link:
https://blog.lobraun.de/2015/06/06/mount-sd-cards-within-virtualbox-on-mac-os-x/

## Accessing Serial Console

You can access your device using serial console on Raspberry Pi 3. Connect the device to your Mac using UART-to-USB cable and follow the procedure below. This should be done outside of the virtual machine.

* On your Mac, open a new Terminal window.
* Go to /dev/ and look for a file like `tty.usbserial-XXXXXXXX`
* Execute `screen /dev/tty.usbserial-XXXXXXXX 115200`.
* Log in as `root`, with password `tizen`.
