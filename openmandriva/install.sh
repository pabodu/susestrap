#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo ">>> You must be root to do this." 1>&2
   exit 1
fi

if [[ -z "$1" ]]; then
    echo ">>> No target directory supplied."
    exit 2
fi

if [[ -z "$2" ]]; then
    echo ">>> No target hostname supplied."
    exit 2
fi

target=$(realpath $1)

if [[ -d $target/dev ]]; then
    echo ">>> Target directory already contains either a partial or full installation: $target"
    echo ">>> Sleeping for 10 seconds... Press Ctrl+C to abort execution."
    sleep 10
fi

mkdir -p $target/dev
mkdir -p $target/sys
mkdir -p $target/proc
#mount -t devtmpfs devtmpfs $target/dev
#mount -t devpts devpts $target/dev/pts
#mount -t sysfs sysfs $target/sys
#mount -t proc proc $target/proc

echo ">>> Enabling repositories"
zypper -R $target addrepo -G --refresh "https://mirror.yandex.ru/openmandriva/rolling/repository/x86_64/main/release/"         "rolling"
zypper -R $target lr -Pu

echo ">>> Refreshing repositories"
zypper -R $target ref

#echo ">>> Adding locks"
#zypper -R $target addlock "*yast*" "*packagekit*" "*PackageKit*" "*plymouth*" "postfix" "pulseaudio"

echo ">>> Installing base packages"
zypper -R $target install filesystem
zypper -R $target install basesystem-minimal

PARAMS=(
    kernel-release-server

    passwd systemd dracut

    btrfs-progs e2fsprogs

    vim

    iproute2 dhcp-client iputils

    dnf openmandriva-repos openmandriva-repos-keys
)
echo ">>> Installing base packages"
zypper -R $target install ${PARAMS[@]}

#echo ">>> Setting up hostname"
#echo $2 > $target/etc/hostname
#echo "127.0.0.1 $2" >> $target/etc/hosts

#echo ">>> Setting up locale.conf: LANG=en_US.UTF-8"
#echo "LANG=en_US.UTF-8" > $target/etc/locale.conf

#echo ">>> Setting up vconsole.conf: KEYMAP=us"
#echo "KEYMAP=us" > $target/etc/vconsole.conf

#echo ">>> Setting up /etc/fstab"
#echo "devpts           /dev/pts         devpts      gid=5,mode=620   0   0" >> $target/etc/fstab
#echo "proc             /proc            proc        defaults         0   0" >> $target/etc/fstab
#echo "tmpfs            /dev/shm         tmpfs       nosuid,nodev,noexec 0   0" >> $target/etc/fstab
#echo "" >> $target/etc/fstab

echo ">>> It's advised that you change these settings if necessary"
echo ">>> It's also advised for you to correctly modify /etc/fstab"
echo ">>> It's also advised for you to set your timezone"
echo ">>> It's also advised for you to install and configure a bootloader"
echo ">>> It's also advised for you to set root password"
echo ">>> Thank you for using SUSEstrap!"
