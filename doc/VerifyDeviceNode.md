# How to verify SD card device node

To verify the device node:

1. Run the following command before inserting the SD card into the Linux computer:

    ```bash
    $ lsblk
    ```

    For example,

    ```bash
    $ lsblk
    NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sda           8:0    0   3.7T  0 disk 
    ├─sda1        8:1    0   128M  0 part 
    └─sda2        8:2    0   3.7T  0 part /media/hskim/Seagate Backup Plus Drive
    nvme0n1     259:0    0   477G  0 disk 
    ├─nvme0n1p1 259:1    0   499M  0 part 
    ├─nvme0n1p2 259:2    0    99M  0 part /boot/efi
    ├─nvme0n1p3 259:3    0    16M  0 part 
    ├─nvme0n1p4 259:4    0 139.7G  0 part 
    └─nvme0n1p5 259:5    0 336.7G  0 part /
    ```

2. Insert the SD card and type the same command again:

    ```bash
    $ lsblk
    ```

    For example,

    ```bash
    $ lsblk
    NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sda           8:0    0   3.7T  0 disk 
    ├─sda1        8:1    0   128M  0 part 
    └─sda2        8:2    0   3.7T  0 part /media/hskim/Seagate Backup Plus Drive
    sdb           8:16   1  14.9G  0 disk 
    ├─sdb1        8:17   1  43.9M  0 part 
    └─sdb2        8:18   1  14.8G  0 part 
    nvme0n1     259:0    0   477G  0 disk 
    ├─nvme0n1p1 259:1    0   499M  0 part 
    ├─nvme0n1p2 259:2    0    99M  0 part /boot/efi
    ├─nvme0n1p3 259:3    0    16M  0 part 
    ├─nvme0n1p4 259:4    0 139.7G  0 part 
    └─nvme0n1p5 259:5    0 336.7G  0 part /
    ```

    The new `sdX` node (where X is a letter) is the device node for the SD card.

    In this example, the device node for the SD card is `sdb`.
