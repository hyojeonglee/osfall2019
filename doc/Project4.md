# Project 4: Geo-tagged File System

* Assigned: 2019-11-21 Thursday 15:00:00 KST
* **Due: 2019-12-17 Tuesday 13:00:00 KST**
* Help Document: [doc](https://github.com/hyojeonglee/osfall2019/tree/master/presentations)

## Introduction

This project is the last OS project. Yay!

In this project, you will develop a new kernel-level mechanism for embedding location information into ext2 file system metadata and use it for access control.

This is a team project.
Each team will have access to its own GitHub repository for collaboration and submission.
If you have not changed your team, you and your team will continue your work on the same repository you worked on for Project 3.
Your final codes and `README.md` document have to be committed into the _proj4_ branch for submission.
Start from the original [kernel source](https://github.com/hyojeonglee/tizen-5.0-rpi3) (you may already have it in your team repository's _master_ branch) and make incremental changes to get things done.

## 0. Necessary `defconfig` Modification

Open ` arch/arm64/configs/tizen_bcmrpi3_defconfig` and add the following 2 lines and remove `CONFIG_EXT2_FS is not set`:

```
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
```

and disable `CONFIG_EXT4_USE_FOR_EXT2` (replace `CONFIG_EXT4_USE_FOR_EXT2=y` with the following): 
```
# CONFIG_EXT4_USE_FOR_EXT2 is not set
```

## 1. Tracking device location (10 pts.)

It would be nice if our devices had GPS sensors to acquire location information, but unfortunately they do not. So we will implement a system call to update the current location of the device.

First, write the following definition of `struct gps_location` on `include/linux/gps.h`.
```c
struct gps_location {
  int lat_integer;
  int lat_fractional;
  int lng_integer;
  int lng_fractional;
  int accuracy;
};
```

Write a new system call which updates the kernel with the current location of the device, and then write a user space program `gpsupdate` that updates the kernel with the given GPS location. The kernel should store the location information in kernel memory space.

The new system call number should be 398, and the prototype should be:

```c
long sys_set_gps_location(struct gps_location __user *loc);
```

This sets

* latitude to `loc->lat_integer` + `loc->lat_fractional` * (10^-6), and
* longitude to `loc->lng_integer` + `loc->lng_fractional` * (10^-6)

Fractional parts of latitude and longitude should be nonnegative and not exceed 999,999. The valid ranges of latitude and longitude are [-90, +90] and [-180, 180], respectively (inclusive ends). `accuracy` should be a nonnegative integer and is measured in meters.

You may assume that any GPS related operations are performed after properly setting the device location.

Please write your system call implementation on `kernel/gps.c`. Also, please write the source code for `gpsupdate` on `test/gpsupdate.c`. (Or if you have top-level directory `tizen-5.0-rpi3`, on `tizen-5.0-rpi3/test/gpsupdate.c`)

## 2. Add GPS-related operations to inode (20 pts.)

Modify the Linux inode operations interface to include location getter/setter functionality, and then implement the new operations for ext2. For this, you have to modify the physical representation of ext2 inodes to include location information.

To modify the inode operations interface, add the following two members to `struct inode_operations` definition in `include/linux/fs.h`:

```c
int (*set_gps_location)(struct inode *);
int (*get_gps_location)(struct inode *, struct gps_location *);
```

Note that function pointer `set_gps_location` does _not_ accept any GPS location structure as its argument - it should use the latest GPS data available in the kernel as set by `gpsupdate` you wrote for Step 1.

You only need to implement this location-related operations **for ext2 file system**. Look in the `fs/` directory for all the file system code, and in the `fs/ext2/` directory for ext2 specific code. You will need to change the physical representation of ext2 inodes on disk by appending the following fields _in order_ to the _end_ of the appropriate ext2 inode structure:

```
i_lat_integer (32-bit)
i_lat_fractional (32-bit)
i_lng_integer (32-bit)
i_lng_fractional (32-bit)
i_accuracy (32-bit)
```

These five fields correspond to `gps_location` structure fields.

You will need to pay close attention to the endianness of the fields you add to the ext2 physical inode structure. These data are to be read by both big _and_ little endian CPUs.

## 3. Update location information for files (15 pts.)

Modify the file system implementation so that it updates location information of regular files when they are **created** or **modified**. That is, call `set_gps_location` you have implemented whenever a regular file is created or modified. A file being "modified" means that its content has changed. ([Learn more](https://unix.stackexchange.com/questions/2464/timestamp-modification-time-and-created-time-of-a-file))

You don't have to care about directories and symbolic links, but if you want to track location information for them, you're free to do so.

## 4. User-space testing for location information (15 pts.)

As you have modified the physical representation of ext2 file system on disk, you also need to modify the user space tool which creates such a file system. You have to use the ext2 file system utilities in [e2fsprogs](http://e2fsprogs.sourceforge.net/). Modify the appropriate file(s) in `e2fsprogs/lib/ext2fs/` to match the new physical layout.

Compile the utilities:

```bash
os@m:~/proj4/e2fsprogs$ ./configure
os@m:~/proj4/e2fsprogs$ make
```

The binary you will be the most interested in is `e2fsprogs/misc/mke2fs`. This tool should now create an ext2 file system with your modifications.

Create a modified ext2 file system using the modified `mke2fs` tool _on your Linux PC_.

```bash
os@m:~/proj4$ dd if=/dev/zero of=proj4.fs bs=1M count=1
os@m:~/proj4$ sudo losetup /dev/loop0 proj4.fs
os@m:~/proj4$ sudo ./e2fsprogs/misc/mke2fs -I 256 -L os.proj4 /dev/loop0
os@m:~/proj4$ sudo losetup -d /dev/loop0
```

If `losetup` fails saying the device or resource is busy, try finding an empty loop device using `losetup -f`.

The file `proj4.fs` should now contain the modified ext2 file system. You can now push it onto your device and mount it (the following assumes you use `sdb`):

```bash
os@m:~/proj4$ sdb push proj4.fs /root/proj4.fs
os@m:~/proj4$ sdb shell
root@raspberry:/root$ mkdir /root/proj4
root@raspberry:/root$ mount -o loop -t ext2 /root/proj4.fs /root/proj4
```

If you do not use `sdb`, simply repeat the steps you usually do to upload a file to your device and to connect to it.

You can now create files and directories in `/root/proj4` which should be geo-tagged.

Write a user space utility named `file_loc` which will output the embedded location information of a file along with its GPS coordinates and a Google Maps link.

In order to retrieve the location information of a file, write a new system call numbered 399 with the following prototype:

```c
long sys_get_gps_location(const char __user *pathname, struct gps_location __user *loc);
```

* On success, the system call should return 0 and `*loc` should be filled with location information for the specified file.
* This should fail with `-EACCES` when the file not is readable by the current user.
* This should fail with `-ENODEV` if no GPS coordinates are embedded in the file.

Please write your system call implementation on `kernel/gps.c`.

The user space utility, `file_loc`, should take exactly one command line argument which is the path to a file. It should then print out the GPS coordinates / accuracy of the specified file and a Google Maps link for the corresponding location. Please write source code for `file_loc` on `test/file_loc.c` (or if you have top-level directory `tizen-5.0-rpi3`, on `tizen-5.0-rpi3/test/file_loc.c`), and write a `Makefile` in `test` directory so that the binaries for `gpsupdate` and `file_loc` can be generated by simply typing `make`.

You need to include the `proj4.fs` file in your final git repository submission, and the file system must contain at least 1 directory and 2 files, all of which must have unique GPS coordinates. Show the output of `file_loc` in your `README.md` when called on each of the files you created.

**IMPORTANT**: Make sure to unmount the file system before pulling off the file from the device, otherwise you risk a corruption. If you cannot unmount it, simply reboot the device and pull off the file.

## 5. Location-based file access (15 pts.)

Modify the file system implementation so that files can be readable only from the location they were created or modified. There are various layers on which you can implement this mechanism: VFS functions, ext2 inode operations, and so on.

You have to consider `accuracy` to allow some error in location. The access to a file should be denied if the location information tied to it does not match that of the device. Use the following algorithm to check this:

1. Draw a circle whose center is the position pinned by the device latitude and longitude, and whose radius is the device accuracy. The device can then be in anywhere within and on the circle.
2. Do the same with the GPS information stored in the file we want to access.
3. If the two circles intersect, it means there is a possibility the two locations match; hence grant access. Revoke otherwise.

You may want to make some geometrical assumptions for the calculation.  Also note that the kernel does not have any floating point or double precision support. Document any assumptions or approximations you have used on `README.md`.

This location-based file access does not replace the existing access control mechanism; rather it's an extra checklist for ext2 file system. That is, if the existing access control mechanism rejects an access, you should not allow it even if the file location matches with the device location.

You do NOT have to handle directories and symbolic links, but if you want to implement extra policies for them, you are free to do so. It is advisable to document extra policies on `README.md`.


You can use `su` to switch from root user to normal user.
```
$ whoami
root
$ su -l owner
$ whoami
owner
```

## Others
- Slides and Demo
    - Send it to the TA's email before the deadline.
    - Title: [OS-ProjX] TeamX slides&demo submission
    - File name: TeamX-slides.ppt(.pdf), TeamX-demo.mp4(.avi….) (send only one video!)


## We're Here to Help You

Any troubles? Questions on [issue board](https://github.com/hyojeonglee/osfall2019/issues) are more than welcome. Discussions between students are also encouraged.

Start early, be collaborative, and still most importantly, have fun!
