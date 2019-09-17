# How to move files into Tizen

To move files from your local Linux machine to your device:

1. Insert your SD card into the Linux computer.

2. Create a new directory to mount `tizen`'s root file system.

3. Figure out the device node of your SD card ([how to verify device node](/doc/VerifyDeviceNode.md)).

4. Assume that your device node is `/dev/sdX`. Then, mount `/dev/sdX2` on your newly created directory.

    For example, if the device node is `/dev/sdb`:
    ```bash
    sudo mount /dev/sdb2 ${mount_dir}
    ```

5. Copy the files that you want to move into the `root` directory, which is in `${mount_directory}`.

    ```bash
    sudo cp ${file_to_move} ${mount_dir}/root
    ```

6. Unmount SD card, put it in your Raspberry Pi 3 device, and check whether the file is successfully copied into the `root` directory using a serial port communication.
