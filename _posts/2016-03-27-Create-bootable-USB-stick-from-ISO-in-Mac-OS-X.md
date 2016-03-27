---
disqus_identifier: 43362371170676917162452558258983273616
layout: post
title: "Create bootable USB stick from ISO in Mac OS X"
date: 2016-03-27 11-06-05 +0800
categories: ['OS X',]
tags: ['OS X', 'Bootable USB', 'ISO',]
---
##### Original: [{{ page.title }}](http://blog.tinned-software.net/create-bootable-usb-stick-from-iso-in-mac-os-x/) at [http://blog.tinned-software.net/](http://blog.tinned-software.net/ "Tinned-Software")

Booting from a USB stick is nowadays more and more important. More and more PCs (and servers) are delivered by default without a CD/DVD drive. To install the OS of your choice, USB sticks provide you the easiest possibility. In fact, it can even work out cheaper than burning a CD or DVD that you just throw away once the version is outdated.

From most Linux distributions the ISO for buring a CD/DVD is available freely on the internet. In this post I'll assume you have already downloaded the bootable ISO image for the OS of your choice, but how to get the ISO image on to the USB stick?

The ISO file you have downloaded contains an image of the entire media. It includes all the files necessary to boot your PC/server. This image format is sadly not directly usable to copy onto USB stick. We first need to convert the image from an ISO to a UDRW(Read/Write Universal Disk Image Format) which we can copy to the USB stick.

Some of the steps to create a botable USB sticks could be done in the GUI as well, but as some of them can't and you have to go to the shell anyway, I decided to do all of the steps in the shell.

## Convert the ISO to UDRW format

Mac OS X provides all the tools needed to convert the ISO image to UDRW. The following command will convert the ISO image to the UDRW format.

    hdiutil convert -format UDRW -o destination_file.img source_file.iso

You will notice that the destination_file.img from the command will create the file destination_file.img.dmg really. This is because the hdiutil program automatically adds the dmg file extension. This is not a problem as the file extension won’t affect the format of the image.

## Prepare the USB stick

Check your USB stick and make a backup if there is any important data on it, as the next steps are going to delete everything on it.

To prepare the USb stick we are going to delete all the partitions on the stick and create an empty partition. To do this we need to know the device name of the USB stick. Open a terminal and execute the following command:

    $ diskutil list

You will see a list of disks and partitions. The goal is to identify the USB stick in this output. Depending on your system configuration your output might look different from this one. This appears to show 3 physical discs but it does not. The /dev/disk1 is a virtual disk created because of the partition encryption ([FileVault 2](http://support.apple.com/kb/HT4790)) I enabled in Mac OS X.

    /dev/disk0
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:      GUID_partition_scheme                        *500.1 GB   disk0
    1:                        EFI                         209.7 MB   disk0s1
    2:          Apple_CoreStorage                         399.5 GB   disk0s2
    3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3
    5:                 Apple_Boot Boot OS X               134.2 MB   disk0s5
    /dev/disk1
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:                  Apple_HFS MacOSX                 *399.2 GB   disk1
    /dev/disk2
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:      GUID_partition_scheme                        *2.0 GB     disk2
    1:       Microsoft Basic Data UNTITLED 1              2.0 GB     disk2s1

As shown in the output above, the connected USB stick is a small 2.0 GB drive with a FAT partition on it. We are now going to remove this partition in the next step. For the following steps we will need the name of the disk which in this case is “/dev/disk2”.

**With the following command the data on the disk (your USB stick) will be deleted!**

    $ diskutil partitionDisk /dev/disk2 1 "Free Space" "unused" "100%"

With this command the USB stick was re-partitioned to have 1 partition without formatting and 100% of the size of the stick. If you check it again with “diskutil list” you will see the changes already, also the USB stick will no longer be shown in the Finder.

## Copy the image to the USB stick

Now we can copy the disk image we created to the USB stick. This is done via the [dd(1)](http://linux.die.net/man/1/dd) command. This command will copy the image to the disk (substitute the appropriate disk name for your USB stick here, as with the re-partitioning command):

    $ dd if=destination_file.img.dmg of=/dev/disk2 bs=1m

The dd command does not show any output before it has finished the copy process, so be patient and wait for it to complete.

    $ diskutil eject /dev/disk2

To eject the USB stick, use the above command. After this is done, the bootable USB stick is ready to be used.

* * *

Read more of posts on Tinned-Software blog at [http://blog.tinned-software.net/](http://blog.tinned-software.net/ "Tinned-Software Blog").
