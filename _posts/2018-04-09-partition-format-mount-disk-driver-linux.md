---
layout: post
title: Partition, format and mount driver on Linux
date: 2018-04-09 14:22:13 +0800
categories: ['linux']
tags: ['linux', 'fdisk', 'mount']
---

- TOC
{:toc}

- - -

## Disk partitioning

**Disk partioning** or **disk slicing** is the creation of one or more regions on a hard disk or other secondary storage, so that an operating system can manage information in each region separately. Partioning is typically the fist step of preparing a newly manufactured disk, before any files or directories have been created. The disk stores the information about the partions' location and sizes in an area known as the **partion table** that the operating system reads before any other part of the disk. Each partion then apears in the operating system as a distinct "logical" disk that use part of the actual disk. System administrators use a program called a partion editor to create, resize, delete, and manipulate the partitions. When a hard driver is installed in a computer, it must be partioned before you can format and use it. Partioning a driver is when you divide the total storage of a driver into different pieces. These pieces are call partions. Once a partion is created, it can then be formatted so that it can be used on a computer.

### Primary, Extended, and Logical Partitions

When partitioning, you'll need to be aware of the difference between primary, extended, and logical partitions. A disk with a traditional partition table can only have up to four partitions. Extended and logical partitions are a way to get around this limitation.

Each disk can have up to four primary partitions or three primary partitions and an extended partition. If you need four partitions or less, you can just create them as primary partitions.

However, let's say you want six partitions on a single drive. You'd have to create three primary partitions as well as an extended partition. The extended partition effectively functions as a container that allows you to create a larger amount of logical partitions. So, if you needed six partitions, you'd create three primary partitions, an extended partition, and then three logical partitions inside the extended partition. You could also just create a single primary partition, an extended partition, and five logical partitions — you just can't have more than four primary partitions at a time.

### Partition a new disk

Use this command `lsblk` to list available disks:

```sh
lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
├─sda1   8:1    0 19.1G  0 part /
├─sda2   8:2    0    1K  0 part
└─sda5   8:5    0  880M  0 part [SWAP]
sdb      8:16   0   20G  0 disk
└─sdb1   8:17   0   20G  0 part /data
sdc      8:32   0   20G  0 disk
```

Also you can use command `fdisk` or `lsscsi`:

```
fdisk -l|grep 'Disk /dev'
Disk /dev/sdb: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
```

```sh
lsscsi
[0:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda
[0:0:1:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sdb
[0:0:2:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sdc
```

Use the command `fdisk /dev/[sda,sdb, ..., hda, hdb, ...]` to partition the new disk:

```sh
fdisk /dev/sdc
```

The basic fdisk commands you need are:

- **m** – print help
- **p** – print the partition table
- **n** – create a new partition
- **d** – delete a partition
- **q** – quit without saving changes
- **w** – write the new partition table and exit

EIDE devices are identifier as *hda*, *hdb*, *hdc*, and *hdd* in the */dev* directory. Partitions on these disk can range from 1 to 16 and are also in the */dev* directory. For example, */dev/hda4* refers to partion 4 on hard disk a (fist EIDE hard disk).

SCSI devices are listed as devices *sda*, *sdb*, *sdc*, *sdd*, *sde*, *sdf*, and *sdg* in the */dev* directory. Similarly, partions on these disks can range from 1 to 16 and also in the */dev* directory. For example, */dev/sda3* refers to partions 3 on SCSI disk a (fisrt SCSI hard disk).

## Disk formatting

**Disk formatting** is the process of preparing a data storage device such as a hard disk driver, solid-state driver, floppy disk or USB flash driver for initial use. In some cases, the formatting operation may also create one or more new file systems. The first part ot formatting process that performs basic medium preparation is often referred to as "low-level formatting". Partioning is the common term for the second part of the process, making the data storage visible to an operating system. The third part of the process, usually termed "high-level formatting" most often refers to the process of generating a new file system. In some operating systems all or parts of these three processes can be combined or repeated at different levels and the term "format" is understood to mean an operation in which a new disk medium is fully prepared to store files.

### Creating an ext2, or ext3, or ext4, or xfs filesystem

Once you've partioned your hard disk using `fdisk` command, use `make2fs` to create *ext2*, *ext3*, *ext4* or *xfs* file system.

- Create an ext2 file system:

    ```sh
    mke2fs /dev/sdc1
    ```

- Create an ext3 file system:

    ```sh
    mkfs.ext3 /dev/sda1
    ```
    
    (or)
    
    ```sh
    mke2fs -j /dev/sda1
    ```

- Create an ext4 file system:

    ```sh
    mkfs.ext4 /dev/sda1
    ```
    
    (or)
    
    ```sh
    mke2fs -t ext4 /dev/sda1
    ```

- Create an xfs file system:

    ```sh
    mkfs.xfs /dev/sda1
    ```
    
    (or)
    
    ```sh
    mke2fs -t xfs /dev/sda1
    ```

#### Converting ext2 to ext3

For example, if you are upgrading */dev/sda2* that is mounted as */home*, from ext2 to ext3, do the following.

```sh
umount /dev/sda2

tune2fs -j /dev/sda2

mount /dev/sda2 /home
```

Note: You really don’t need to umount and mount it, as ext2 to ext3 conversion can happen on a live file system. But, I feel better doing the conversion offline.

#### Converting ext3 to ext4

If you are upgrading */dev/sda2* that is mounted as */home*, from ext3 to ext4, do the following.

```sh
umount /dev/sda2

tune2fs -O extents,uninit_bg,dir_index /dev/sda2

e2fsck -pf /dev/sda2

mount /dev/sda2 /home
```

Again, try all of the above commands only on a test system, where you can afford to lose all your data.

## Mount

**Mounting** is a process by which the operating system makes files and diretories on a storage device (such as hard driver, CD-ROM, or network share) available for user to access via the computer's file system.

In general, the process of mounting comprises operating system acquiring access to the storage medium, reading, processing file system structure and metadata on it; before registering them to the virtual file system (VFS) component.

The exact location in VFS that the newly-mouted medium got registered is called **mount point** (a mount point is a physical location in the partion used as a root filesystem); when the mounting process is completed, the user can access files and directories on the medium from there.

An opposite process of mounting is called **unmounting**, in which the operating system cuts off all user access to files and directories on the mount point, writes the remaining queue of user data to the storage device, refreshes file system metadata, then relinquishes access to the device; making the storage safe for removal.

Normally, when the computer is shutting down, every mounted storage will undergo un unmouting process to ensure that all queued data got written, and to preserve integrity of file system structure on the media.

### Checking Your Available Partitions

To see your devices and their separate filesystems, simply use this command:

```sh
lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
├─sda1   8:1    0 19.1G  0 part /
├─sda2   8:2    0    1K  0 part
└─sda5   8:5    0  880M  0 part [SWAP]
sdb      8:16   0   20G  0 disk
└─sdb1   8:17   0   20G  0 part /data
sdc      8:32   0   20G  0 disk
├─sdc1   8:33   0    1G  0 part /tmp/b
├─sdc2   8:34   0    1G  0 part
├─sdc3   8:35   0  500M  0 part
├─sdc4   8:36   0    1K  0 part
├─sdc5   8:37   0  500M  0 part /tmp/a
└─sdc6   8:38   0   10G  0 part
```

### Mounting With Udisks

Udisks is an important piece of software used in many Linux distributions. It is responsible for managing storage devices such as USB flash storage, and hard disk drives. With it comes a command line tool called udisksctl. Under this tool, all of your partitioning commands follow this pattern:

```sh
udisksctl [command]
```

Simple isn’t it? To mount your desired partition, use this command, substituting the last bit with the right partition:

```sh
udisksctl mount -b /dev/sd[b1, b2, etc.]
```

### Unmounting With Udisks

Once you’re done with your USB, or any other miscellaneous device, you need to safely remove it from your Linux box to prevent data loss. This is done by unmounting the foreign file-system, decoupling it from your own.

Doing this is as simple as substituting *mount* with *unmount*:

```sh
udisksctl unmount -b /dev/sd[b1, b2, etc.]
```

### Mounting the Old-School Way

To mount a partition:

```sh
sudo mount /dev/sd[b1, b2, etc.] /mnt
```

### Unmounting the Old-School Way

Strangely enough, the command to unmount a partition is not unmount, but umount. Keep that in mind. Unlike mounting, you don’t need to specify the location of your mount point — just the device will do:

```sh
sudo umount /dev/sd[b1, b2, etc.]
```

### Update /etc/fstab file to automount partitions at startup

Use `blkid` or `lsblk -f` to print the universally unique identifier for a device; this may be used with UUID= as a more robust way to name devices that works even if disks are added and removed.

```sh
sudo blkid
/dev/sda1: UUID="b19522be-98e3-4754-af48-14396eae021f" TYPE="ext4" PARTUUID="2ed9e1c9-01"
/dev/sdb1: UUID="a25ec7d0-0651-4ec8-b888-eeec8d6c2488" TYPE="ext3" PARTUUID="c153418e-01"
/dev/sda5: UUID="9ae8f2eb-f27d-4335-a7ee-cda1a2d3e2e0" TYPE="swap" PARTUUID="2ed9e1c9-05"
/dev/sdc1: UUID="226e0aaa-66d3-4504-bc84-5f6981670e53" TYPE="ext2" PARTUUID="913e673b-01"
/dev/sdc5: UUID="20b8bb5f-e637-4425-adc1-d586de0c03a3" TYPE="ext4" PARTUUID="913e673b-05"
/dev/sdc2: UUID="fc4b7d77-542b-43af-b51c-8633224a4f4c" TYPE="ext4" PARTUUID="913e673b-02"
/dev/sdc3: UUID="14de4bde-708c-479b-9e24-dbccb3954f14" TYPE="ext4" PARTUUID="913e673b-03"
/dev/sdc6: UUID="293e6f88-ad5b-4f90-b7d2-088b02aab0f8" TYPE="ext4" PARTUUID="913e673b-06"
```

Use `df -hT -text4` to show all available ext4 filesystems:

```sh
df -hT -text4
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sda1      ext4   19G   13G  5.5G  70% /
```

Append a new entry into */etc/fstab*:

```sh
tail -n 1 /etc/fstab
UUID=226e0aaa-66d3-4504-bc84-5f6981670e53       /tmp/a  ext4    defaults        0       3
```

Use `mount -a` to mount all filesystems mentioned in fstab:

```sh
sudo mount -a

df -hT -text4
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sda1      ext4   19G   13G  5.5G  70% /
/dev/sdc1      ext4 1008M  1.3M  956M   1% /tmp/a
```

## An example to partion a new disk

The follow example create three primary partions and one extended partion with two logical partions:

```sh
$ fdisk /dev/sdc

Welcome to fdisk (util-linux 2.29.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x913e673b

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-41943039, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-41943039, default 41943039): +1G

Created a new partition 1 of type 'Linux' and of size 1 GiB.

Command (m for help): p
Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x913e673b

Device     Boot Start     End Sectors Size Id Type
/dev/sdc1        2048 2099199 2097152   1G 83 Linux

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (2-4, default 2):
First sector (2099200-41943039, default 2099200):
Last sector, +sectors or +size{K,M,G,T,P} (2099200-41943039, default 41943039): +1G

Created a new partition 2 of type 'Linux' and of size 1 GiB.

Command (m for help): n
Partition type
   p   primary (2 primary, 0 extended, 2 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (3,4, default 3):
First sector (4196352-41943039, default 4196352):
Last sector, +sectors or +size{K,M,G,T,P} (4196352-41943039, default 41943039): +500M

Created a new partition 3 of type 'Linux' and of size 500 MiB.

Command (m for help): p
Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x913e673b

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 2099199 2097152    1G 83 Linux
/dev/sdc2       2099200 4196351 2097152    1G 83 Linux
/dev/sdc3       4196352 5220351 1024000  500M 83 Linux

Command (m for help): n
Partition type
   p   primary (3 primary, 0 extended, 1 free)
   e   extended (container for logical partitions)
Select (default e): e

Selected partition 4
First sector (5220352-41943039, default 5220352):
Last sector, +sectors or +size{K,M,G,T,P} (5220352-41943039, default 41943039):

Created a new partition 4 of type 'Extended' and of size 17.5 GiB.

Command (m for help): p
Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x913e673b

Device     Boot   Start      End  Sectors  Size Id Type
/dev/sdc1          2048  2099199  2097152    1G 83 Linux
/dev/sdc2       2099200  4196351  2097152    1G 83 Linux
/dev/sdc3       4196352  5220351  1024000  500M 83 Linux
/dev/sdc4       5220352 41943039 36722688 17.5G  5 Extended

Command (m for help): n
All primary partitions are in use.
Adding logical partition 5
First sector (5222400-41943039, default 5222400):
Last sector, +sectors or +size{K,M,G,T,P} (5222400-41943039, default 41943039): +500M

Created a new partition 5 of type 'Linux' and of size 500 MiB.

Command (m for help): p
Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x913e673b

Device     Boot   Start      End  Sectors  Size Id Type
/dev/sdc1          2048  2099199  2097152    1G 83 Linux
/dev/sdc2       2099200  4196351  2097152    1G 83 Linux
/dev/sdc3       4196352  5220351  1024000  500M 83 Linux
/dev/sdc4       5220352 41943039 36722688 17.5G  5 Extended
/dev/sdc5       5222400  6246399  1024000  500M 83 Linux

Command (m for help): n
All primary partitions are in use.
Adding logical partition 6
First sector (6248448-41943039, default 6248448):
Last sector, +sectors or +size{K,M,G,T,P} (6248448-41943039, default 41943039): +10G

Created a new partition 6 of type 'Linux' and of size 10 GiB.

Command (m for help): p
Disk /dev/sdc: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x913e673b

Device     Boot   Start      End  Sectors  Size Id Type
/dev/sdc1          2048  2099199  2097152    1G 83 Linux
/dev/sdc2       2099200  4196351  2097152    1G 83 Linux
/dev/sdc3       4196352  5220351  1024000  500M 83 Linux
/dev/sdc4       5220352 41943039 36722688 17.5G  5 Extended
/dev/sdc5       5222400  6246399  1024000  500M 83 Linux
/dev/sdc6       6248448 27219967 20971520   10G 83 Linux

Command (m for help): F
Unpartitioned space /dev/sdc: 7 GiB, 7537164288 bytes, 14721024 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes

   Start      End  Sectors Size
27222016 41943039 14721024   7G

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk
├─sda1   8:1    0 19.1G  0 part /
├─sda2   8:2    0    1K  0 part
└─sda5   8:5    0  880M  0 part [SWAP]
sdb      8:16   0   20G  0 disk
└─sdb1   8:17   0   20G  0 part /data
sdc      8:32   0   20G  0 disk
├─sdc1   8:33   0    1G  0 part
├─sdc2   8:34   0    1G  0 part
├─sdc3   8:35   0  500M  0 part
├─sdc4   8:36   0    1K  0 part
├─sdc5   8:37   0  500M  0 part
└─sdc6   8:38   0   10G  0 part
```

## References

1. Disk partitioning, [https://en.wikipedia.org/wiki/Disk_partitioning](https://en.wikipedia.org/wiki/Disk_partitioning)
1. Beginner Geek: Hard Disk Partitions Explained, [https://www.howtogeek.com/184659/beginner-geek-hard-disk-partitions-explained/](https://www.howtogeek.com/184659/beginner-geek-hard-disk-partitions-explained/)
1. Partition the new disk, [https://www.tldp.org/HOWTO/Hard-Disk-Upgrade/partition.html](https://www.tldp.org/HOWTO/Hard-Disk-Upgrade/partition.html)
1. Disk formatting, [https://en.wikipedia.org/wiki/Disk_formatting](https://en.wikipedia.org/wiki/Disk_formatting)
1. Mounting Hard Disks and Partitions Using the Linux Command Line, [https://www.makeuseof.com/tag/mounting-hard-disks-partitions-using-linux-command-line/](https://www.makeuseof.com/tag/mounting-hard-disks-partitions-using-linux-command-line/)
1. File system, [https://en.wikipedia.org/wiki/File_system](https://en.wikipedia.org/wiki/File_system)
1. Linux File Systems: Ext2 vs Ext3 vs Ext4, [https://www.thegeekstuff.com/2011/05/ext2-ext3-ext4/](https://www.thegeekstuff.com/2011/05/ext2-ext3-ext4/)
1. What is meant by mounting a drive?, [https://kb.iu.edu/d/anqk](https://kb.iu.edu/d/anqk)
1. Linux Hard Disk Format Command - nixCraft, [https://www.cyberciti.biz/faq/linux-disk-format/](https://www.cyberciti.biz/faq/linux-disk-format/)
1. Editing fstab to automount partitions at startup, [https://community.linuxmint.com/tutorial/view/1513](https://community.linuxmint.com/tutorial/view/1513)
1. fstab - Debian Wiki, [https://wiki.debian.org/fstab](https://wiki.debian.org/fstab)
