# Project 2: Weighted Round-Robin Scheduler

* Assigned: 2019-10-08 Tuesday 15:00:00 KST
* **Due: 2019-10-31 Thursday 13:00:00 KST**
* Help Document: [doc](https://github.com/hyojeonglee/osfall2019/tree/master/presentations)

## Introduction

In this project, we will build our own CPU scheduler in the Tizen Linux kernel. Then, we test the scheduler with Raspberry Pi.

This is a team project.
Each team will have access to its own GitHub repository (e.g. hyojeonglee/osfall2019-team1) for collaboration and submission.
If you have not changed your team, you and your team will continue your work on the same repository you worked on for Project 2.
Your final codes and `README.md` document have to be committed into the _proj2_ branch for submission.
Start from the original [kernel source](https://github.com/hyojeonglee/tizen-5.0-rpi3) (you may already have it in your team repository's _master_ branch) and make incremental changes to get things done.

> There will be a limitaion in number of process running concurrently due to the device(rpi) architecture. Maximum 5~6 processes will be used for evaluation.

## 1. A Symmetric Multiprocessor Weighted Round-Robin Scheduler (60 pts.)

Add a new scheduling policy to the Linux kernel to support _weighted round-robin_ scheduling.
Call this policy `WRR`.
The algorithm should run in constant time and work as follows:

  1. Multiprocessor systems must be fully supported.
  2. The base time slice (quantum) should be 10ms.
     Weights of tasks can range between 1 and 20 (inclusively).
     A task's time slice is determined by its weight multiplied by the base time slice.
     The default weight of tasks should be 10 (a 100ms time slice).
  3. If the weight of a task currently on a CPU is changed, it should finish its time quantum as it was before the weight change (i.e., increasing the weight of a task currently on a CPU does not extend its current time quantum).
  4. When deciding which CPU a task should be assigned to, it should be assigned to the CPU with the smallest total weight (i.e., sum of the weights of the tasks on the CPU's run queue). However, one CPU run queue must be left empty: no WRR task should be running on it (but may sleep on it).
  5. Periodic load balancing should be implemented such that a single task from the run queue with the highest total weight should be moved to the run queue with the lowest total weight, provided there exists a task in the highest run queue that can be moved to the lowest run queue without causing the lowest run queue's total weight to become greater than or equal to the highest run queue's total weight.
     The task that should be moved is the highest weighted eligible task which can be moved without causing the weight imbalance to reverse.
     Tasks that are currently running are not eligible to be moved and some tasks may have restrictions on which CPU they can be run on.
     Load balancing should be attempted every 2000ms. Implementation must consider cases with a hotplug especially in arm64. 

The Linux scheduler implements individual scheduling classes corresponding to different scheduling policies.
For this project, you need to create a new scheduling class, `wrr_sched_class`, for the `WRR` policy, and implement the necessary functions in `kernel/sched/wrr.c`.
You can find some good examples of how to create a scheduling class in `kernel/sched/rt.c` and `kernel/sched/fair.c`.
Other interesting files that will help you understand how the Linux scheduler works are `kernel/sched/core.c`, `kernel/sched/sched.h` and `include/uapi/linux/sched.h`.
While there is a fair amount of code in these files, one of the key goals of this project is for you to understand how to abstract the scheduler code so that you learn in detail the parts of the scheduler that are crucial for this assignment and ignore the parts that are not.

Your scheduler should operate alongside the existing Linux scheduler.
Therefore, you should add a new scheduling policy, `SCHED_WRR`.
The value of `SCHED_WRR` should be 7.
Tasks will manually be switched to use `SCHED_WRR` using system call `sched_setscheduler()`.
The weight of a task and the `SCHED_WRR` scheduling flag should be _inherited_ by the child of any forking task.

Only tasks whose policies are set to `SCHED_WRR` should be considered for selection by your new scheduler.
If a process' scheduler is set to `SCHED_WRR` after previously being set to another scheduler, its weight should be the default weight.
Tasks using the `SCHED_WRR` policy should take priority over tasks using the `SCHED_NORMAL` policy, but _not_ over tasks using the `SCHED_RR` or `SCHED_FIFO` policies of real time scheduler.

Proper synchronization and locking is crucial for an [SMP](https://en.wikipedia.org/wiki/Symmetric_multiprocessing) scheduler, but this is not easy.
For this project, assume the scheduler will only run on SMP systems.
Pay close attention to the kind of locking used in existing kernel schedulers.

For setting and getting the weights, you are to implement the following system calls:
```c
/*
 * Set the SCHED_WRR weight of process, as identified by 'pid'.
 * If 'pid' is 0, set the weight for the calling process.
 * System call number 398.
 */
long sched_setweight(pid_t pid, int weight);

/*
 * Obtain the SCHED_WRR weight of a process as identified by 'pid'.
 * If 'pid' is 0, return the weight of the calling process.
 * System call number 399.
 */
long sched_getweight(pid_t pid);
```

Only the administrator (`root` user) and the user who owns the process may adjust its weight using `sched_setweight()`.
Furthermore, only the administrator may increase the weight of a process.
Any user should be able to call `sched_getweight()`.
It is an error to try and set the weight on a process not using the `SCHED_WRR` policy.
The system calls should handle all errors appropriately.
The system calls should be implemented in `kernel/sched/core.c`.

The system calls refer to the process whose ID is specified by _pid_, i.e., only one task's weight should be changed in the kernel.
(In _overly simplistic_ terms, the weight of the task_struct whose pid is specified by _pid_ is changed).
Or you can implement it such that the process represented by _pid_ and all of its threads' weights are changed.
This implementation is more complicated so there is more potential for it to be implemented incorrectly.

> Error handling in `sched_getweight()` and implementaion for `Group_scheduling` will not be condsidered in the evaluation. 

## 2. Investigate (10 pts.)

Demonstrate that your scheduler works with a test program that calculates the prime factorization of a number using the naive _Trial Division_ method.
Track how long this program takes to execute with different weightings set and plot the result.
You should choose a number to factor that will take sufficiently long to calculate the prime factorization of, such that it demonstrates the effect of weighting has on its execution time.
You can measure the execution time either internally in the program's code or externally so long as it is sufficiently accurate to show the effect of weighting.

You should provide a complete set of results that show all your tests.
If there are any results that do not yield execution time proportional to weights, explain why.
Your results and any explanations should be put in the `README.md` file in the project branch of your team's repository.
Your plot should be named `plot.pdf` and should be put next to the `README.md` file.

## 3. Improve the WRR scheduler (10 pts.)

From the above investigation, have you noticed any deficiencies?
Sketch a design to improve the WRR scheduler.
Describe your proposal in `EXTRA.md` (in your home repository of _proj2_ branch) and explain the rationale behind your design.
For this problem, you do not submit any actual code that works.
Note that this is an open question.
There is no single answer to the question.

### Important Hints/Tips - Kernel / Scheduler Hacking:

For this project, the default kernel configurations for Raspberry Pi has to be updated to include the `debugfs`, and some basic scheduler debugging.
These tools can be of great value as you work on this assignment.
Debugfs documentation can be found [here](https://www.kernel.org/doc/Documentation/filesystems/debugfs.txt), and scheduler debugging information can be found in `/proc/sched_debug` and `/proc/schedstat` respectively.

To make use of `/proc/sched_debug` and `/proc/schedstat` information, you should first enable `CONFIG_SCHED_DEBUG` and `CONFIG_SCHEDSTATS` options in `arch/arm64/configs/tizen_bcmrpi3_defconfig`.
You can modify `sched/debug.c` and `sched/stats.c` - you may want to add something while you debug!
The `debugfs` can be mounted with `mount -t debugfs none /sys/kernel/debug` if not already mounted.

## Others
- Slides and Demo
    - Send it to the TA's email before the deadline.
    - Title: [OS-ProjX] TeamX slides&demo submission
    - File name: TeamX-slides.ppt(.pdf), TeamX-demo.mp4(.avi….) (send only one video!)


## We're Here to Help You

Any troubles? Questions on [issue board](https://github.com/hyojeonglee/osfall2019/issues) are more than welcome. Discussions between students are also encouraged.

Start early, be collaborative, and still most importantly, have fun!
