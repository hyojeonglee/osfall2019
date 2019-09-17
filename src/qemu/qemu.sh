#!/bin/bash
exec qemu-system-aarch64 -nographic -M virt -m 2048 -cpu cortex-a53 -smp cores=4 -kernel ./arch/arm64/boot/Image -initrd ../tizen-image/ramdisk.img -append "bootmode=ramdisk rw root=/dev/ram0 kgdboc=ttyS0,115200 kgdbwait" -serial mon:stdio \
  -drive file=../tizen-image/rootfs.img,format=raw,if=sd,id=rootfs -device virtio-blk-device,drive=rootfs \
  -drive file=../tizen-image/boot.img,format=raw,if=sd,id=boot -device virtio-blk-device,drive=boot \
  -drive file=../tizen-image/modules.img,format=raw,if=sd,id=modules -device virtio-blk-device,drive=modules \
  -drive file=../tizen-image/system-data.img,format=raw,if=sd,id=system-data -device virtio-blk-device,drive=system-data
