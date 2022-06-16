#!/usr/bin/env bash

set -ex

	LAYER=999-build
	echo LAYER=${LAYER}
	mkdir -p /debian-${LAYER}
	mount -t tmpfs tmpfs /debian-${LAYER}
	mount -t aufs -o remount,prepend:"/debian-${LAYER}",mod:"/debian-${P_LAYER}"=ro aufs /debian
	mount --bind /debian-${LAYER} /debian/run/initramfs/memory/changes
	mount --bind /debian-tmp /debian/tmp
	mount -t proc proc /debian/proc
	mount -t devpts devpts /debian/dev/pts
	mount -t sysfs sysfs /debian/sys
    cat > /debian/tmp/run-${LAYER}.sh << EOF
#!/usr/bin/env bash
set -ex
mount -t tmpfs tmpfs /mnt
mkdir -p /mnt/boot /mnt/root
/tmp/linux-live/Aiko/debian11/build
/tmp/gen_slax_usb.sh /mnt/boot /mnt/root
cp /tmp/*.sb /mnt/root/slax/modules
mv /mnt/root/slax/modules/005-zsh.sb /mnt/root/slax
#umount /mnt
EOF
	chroot /debian /bin/zsh --login

	#-- undo last layer
	#umount /debian/proc ; umount /debian/dev/pts ; umount /debian/sys ; umount /debian/tmp ; umount /debian/run/initramfs/memory/changes
	#P_LAYER=${LAYER}


mount --bind /dev /debian/dev
mkdir -p /slax/boot /slax/root ; mount /dev/sdb1 /slax/boot ; mount /dev/sdb2 /slax/root ; /tmp/gen_slax_usb.sh /slax/boot /slax/root ; cp /tmp/*.sb /slax/root/slax/modules ; mv /slax/root/slax/modules/005-zsh.sb /slax/root/slax ; sync
umount /slax/boot /slax/root

#umount /debian/proc ; umount /debian/dev ; umount /debian/dev/pts ; umount /debian/sys ; umount /debian/tmp ; umount /debian/run/initramfs/memory/changes
apt reinstall libsigsegv2 libmpfr6

# https://askubuntu.com/questions/949760/dpkg-warning-files-list-file-for-package-missing
