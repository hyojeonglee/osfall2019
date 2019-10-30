# Project 3: Rotation Lock

* Assigned: 2019-10-31 Thursday 15:00:00 KST
* **Due: 2019-11-21 Thursday 13:00:00 KST**
* Help Document: [doc](https://github.com/hyojeonglee/osfall2019/tree/master/presentations)

## Introduction

This assignment includes implementing a new kernel synchronization primitive in Linux.
It provides a reader-writer lock based on device rotation.

This is a team project.
Each team will have access to its own GitHub repository for collaboration and submission.
If you have not changed your team, you and your team will continue your work on the same repository you worked on for Project 1.
Your final code and `README.md` document have to be committed into the _proj3_ branch for submission.
Start from the original [kernel source](https://github.com/hyojeonglee/tizen-5.0-rpi3) (you may already have it in your team repository's _master_ branch) and make incremental changes to get things done.

## 1. A user-space daemon to pass device rotation into the kernel

On the Tizen platform, device orientation can be accessed via an on-board [orientation sensor](https://developer.tizen.org/development/guides/native-application/location-and-sensors/device-sensors#orientation) device.
Using the sensor, a Tizen device detects its orientation in three dimensions.
However, Raspberry Pi devices do not have one, so we will use a fake one-dimensional orientation (_device rotation_) here to simplify the project.
Moreover, we provide a daemon that updates this fake device rotation information, called [rotd](https://github.com/hyojeonglee/osfall2019/blob/master/src/proj3/rotd.c), for you to save time. :-)
The daemon we provide updates the rotation value in the sequence of `0, 30, 60, ... 330, 0, ...` in a fixed frequency (e.g., 2 seconds).
Make sure you have this daemon always running.
The daemon passes the fake values to kernel using the following system call and type.

```c
/*
 * sets the current device rotation in the kernel.
 * syscall number 398 (you may want to check this number!)
 */
long set_rotation(int degree); /* 0 <= degree < 360 */
```

You should write `set_rotation` system call by yourself, which updates the rotation information in the kernel.
All rotation related functions should be placed in `kernel/rotation.c`, and in `include/linux/rotation.h`.

## 2. Rotation-based reader/writer locks (45 pts.)

Design and implement a new kernel synchronization primitive that will provide reader-writer locks based on the device rotation.
Reader-writer locks work by allowing several readers to grab the lock at the same time, but only a single writer can grab the lock at any time.
**You should make sure not to starve writers:** if a reader holds a lock and a writer wants to take the lock, no more readers can take the lock - they should wait.

A lock is defined by a range of the rotation of the device.
For example, if a writer grabs the lock for the degree ranging from 30 to 60 (represented as _[30, 60]_), then readers (or writers) cannot grab any locks in that area until the writer releases the lock.
However, readers (or a single writer) can grab a lock for the range [180, 210] (if the device rotation degree is between 180 and 210), because the range does not overlap with the range [30, 60] of acquired write lock.

If a process wants to grab a lock (either read or write lock) for a range, which does not cover the current physical device rotation, the process should block until the device is rotated into that range.
A user space process can hold the lock as long as it wishes, and either eventually gives it up voluntarily or is forced to give it up when the process dies.
While locks are only obtained when the device is in the corresponding rotation, locks can be released irrespective of the device rotation.

When the device rotation is updated in the kernel, the processes that are waiting to grab a lock on a range entered by the new rotation should be allowed to grab the lock (making sure readers and writers don't grab the lock at the same time).
If no processes are waiting for the particular rotation when it is updated in the kernel, then the operation has no effect.
The API for this synchronization mechanism is the following set of new system calls which you will implement:

```c
/*
 * Take a read/or write lock using the given rotation range
 * returning 0 on success, -1 on failure.
 * system call numbers 399 and 400
 */
long rotlock_read(int degree, int range);  /* 0 <= degree < 360 , 0 < range < 180 */
long rotlock_write(int degree, int range); /* degree - range <= LOCK RANGE <= degree + range */

/*
 * Release a read/or write lock using the given rotation range
 * returning 0 on success, -1 on failure.
 * system call numbers 401 and 402
 */
long rotunlock_read(int degree, int range);  /* 0 <= degree < 360 , 0 < range < 180 */
long rotunlock_write(int degree, int range); /* degree - range <= LOCK RANGE <= degree + range */
```

You should modify the `set_rotation` system call to unblock processes waiting on a lock that covers the new rotation.
You should choose to allow either all blocked readers (may have different rotation ranges) to take the lock or a single blocked writer to take the lock.
When a lock is taken by one or multiple processes, the processes are unblocked and return to user space.
Your strategy to select either readers or a writer should consider fairness as a criterion.

As mentioned above, you should implement the synchronization primitives so that they follow a prevention policy which avoids writer starvation.
Assume that a writer wants to acquire a lock with a range `R`, and the current rotation degree is located in `R`.
In such a case, the writer cannot grab the lock because another reader is holding a lock with a range `R'` which overlaps with `R`; the writer should wait for the reader to release its lock.
Under such circumstances, other readers with ranges that overlap with `R` should not be allowed to grab locks even though the current degree is located in their target ranges, in order to prevent writer starvation.
In short, "if a reader holds a lock and a writer wants to take the lock, no more readers can take the lock - they should wait" is the desired policy for preventing starvation.

If there are no processes waiting on the changed device rotation degree, then nothing happens.
Modify the return value of the system call (`set_rotation`) so that it returns -1 on error, and the total number of processes awoken (processes acquired the lock) on success (0 or more).

Note that a process cannot release locks acquired by other processes.
Assume that there are two processes A and B, and each of them holds a read lock of range [0, 30].
Be careful to make sure that the kernel does not release the read lock held by process A when process B tries to release its read lock of range [0, 30].

You should begin by thinking carefully about the data structures that you will need to solve this problem.
Your system will need to support having multiple processes blocking on different ranges at the same time, so you will probably need a set of range descriptor data structures, each of which identifies an event.
Those data structures will probably need to be put in a list (or other data structures) from which your code can find the appropriate range descriptor corresponding to the rotation degree (or range) that you need.
Space for the range descriptors should be dynamically allocated when the event occurs, most likely using the kernel functions `kmalloc()` and `kfree()`.

You should not make any assumptions about whether the system is a uniprocessor or multiprocessor system.
**Be sure to properly synchronize access to your data structures.**
Moreover, be sure to select the appropriate synchronization primitives such that they are both correct and efficient, in this order.
For instance, you should prefer a spinlock over a semaphore _if and only if_ you don't plan to sleep while holding it.

There are several ways to block the running process.
You can choose to work at the level of wait queues using either the associated low-level routines such as `add_wait_queue()`, `remove_wait_queue()`, or the higher-level routines such as `prepare_to_wait()`, `finish_wait()`.
You can find code examples both in the book (pages 58 - 61 of _Linux Kernel Development_) and in the kernel.
If you prefer to use functions such as `interruptible_sleep_on()` and `sleep_on()`, then plan carefully because they can be racy in certain circumstances.
You can also use `set_current_state(TASK_INTERRUPTIBLE)` and `schedule()` to achieve the same thing.
Investigate these kernel routines and choose the most appropriate one for you.
As always, you are encouraged to look for existing kernel code that performs similar tasks and follow the conventions and practices it provides.

**HINT**: a useful method to guarantee the validity of a data structure in the presence of concurrent create, access and delete operations, is to maintain a reference count for the object.
Then, the object should only be freed by the last user.
The file system, for example, keeps a reference count for _inodes_: when a process opens a file the reference count of the inode is incremented.
Thus if another process deletes the file, the inode remains valid in the system (despite invisible) because its count is positive.
The count is decremented when the process closes the corresponding file descriptor, and if it reaches zero then the inode is freed.
A reference count must be protected against concurrent access, either using explicit synchronization or using atomic types (see `atomic_t` in Chapter 10 of the _Linux Kernel Development_ book).

## 3. Write two C programs to test the system (10 pts.)

**Save your C program as : `test/selector.c`, `test/trial.c` in your team repository.**

Determining the prime factors of a large number can be useful if, for example, you want to break an encryption system.
Assume that your device is a mobile phone, not a Raspberry Pi.
Your device is just a computer like any other computer, so you may want to use your device for this purpose.
However, you do not want your device to be calculating prime numbers when you are holding it and doing things with it.
You only want it to calculate when the current degree is in a specific range (0 <= degree <= 180).

Your programs consist of a data source program (`selector`) and a calculator program (`trial`) that calculates the prime number factorization of source data.
The details of the programs are as follows:

* **selector:**
A program accepts a starting integer as the only argument.
When running, first, your program must take the write lock for when the device is positioned at 0 <= degree <= 180.
Then, it writes the integer from the argument to a file called `integer` in the current working directory.
When the integer has been written, the write lock must be released and re-acquired before writing the last integer + 1 to the same file (overwriting the content of the file).
Your program should run until terminated using `Ctrl+C` by user.
Before releasing the write lock, your program should output the integer to standard output.
Your screen should look like the following:
```bash
$ ./selector 7492
selector: 7492
selector: 7493
selector: 7494
...
```
* **trial:**
A program accepts an integer identifier as the only argument.
This program will acquire a read lock when the device is in a certain rotation ([0, 180]).
After taking the lock, it will open the file called `integer` in the current working directory, calculate the prime number factorization of the integer, and write the result to the standard output.
When done, it will close the file and release the read lock.
This program calculates the factorization using the naive _Trial Division_ method.
Similar to the `selector` program, this program should run until terminated using `Ctrl+C` by user.
Your screen should look like the following:
```bash
$ ./trial 0
trial-0: 7492 = 2 * 2 * 1873
trial-0: 7493 = 59 * 127
trial-0: 7494 = 2 * 3 * 1249
...
```

First, run the selector and then run two trials using different identifiers concurrently.
You can use three independent shells for each program, or use a single shell and shell commands such as `&`, `Ctrl+Z`, and `bg`.
Verify that your rotation lock works well by making sure that no more numbers are output to the screen when the device rotation is outside of the selector & trial's designated rotation range.


## Filesystem Permissions
It is set to mount the `/` as read-only by default; you will have to override this first in order to make your test program work.
You can do this by typing:
```bash
mount -o rw,remount /dev/mmcblk0p2 /
```
Please make sure `/dev/mmcblk0p2` is the partition mounted to `/`. You can check this by typing `df`.
If you want to make this change permanent, simply edit `/etc/fstab` and remove the `ro` option.

## Others
- Slides and Demo
    - Send it to the TA's email before the deadline.
    - Title: [OS-ProjX] TeamX slides&demo submission
    - File name: TeamX-slides.ppt(.pdf), TeamX-demo.mp4(.avi….) (send only one video!)


## We're Here to Help You

Any troubles? Questions on [issue board](https://github.com/hyojeonglee/osfall2019/issues) are more than welcome. Discussions between students are also encouraged.

Start early, be collaborative, and still most importantly, have fun!
