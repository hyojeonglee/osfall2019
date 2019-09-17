# Setup on Windows PC

## Installing the Requirements

### Oracle VM VirtualBox and Extension Pack

![VirtualBoxDownload](/doc/assets/Win00VirtualBoxDownload.PNG)

* Download Oracle VM VirtualBox and Extension Pack from [here](https://www.virtualbox.org/wiki/Downloads).
* Install VirtualBox.

![VirtualBoxPreferences](/doc/assets/Win01VirtualBoxPreferences.PNG)
![VirtualBoxInstallExtension](/doc/assets/Win02VirtualBoxInstallExtension.PNG)

* Install VirtualBox Extension Pack.

### PuTTY

Download PuTTY from [here](http://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) and install it. You may install all the PuTTY utilities using MSI package, or download `putty.exe` standalone binary.

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
http://rizwanansari.net/access-sd-card-on-linux-from-windows-using-virtualbox/

## Accessing Serial Console

You can access your device using serial console on Raspberry Pi 3. Connect the device to your PC and follow the procedure below.

### Identifying the Port

Make sure the device has turned and connected to the PC.

![IdentifyingDevice](/doc/assets/Win03IdentifyingDevice.PNG)

Open start menu, click run, type `devmgmt.msc` and hit <kbd>Enter</kbd>. On the Device Manager, lookup for USB Serial Port (or Prolific USB-to-Serial Comm Port). In the example picture above, `COM4` is the debug console device.

** Note that if you have a connection issue like the image below, you may fix it with the following instruction: http://ifamilysoftware.com/news37.html

![ConnectionError](/doc/assets/Win04PuttyError.PNG)

### Using PuTTY to Open the Console

Open PuTTY and configure the destination with the following parameters.

* Connection type: Serial
* Serial line: `COM4` (you may have to modify this)
* Speed: 115200

And click Open.

![PuttyLogin](/doc/assets/Win05Putty.PNG)

Reboot the device. If you can see boot messages from Raspberry Pi 3, you're on the right way.
