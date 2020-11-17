#!/usr/bin/sh

mkdir chroot
debootstrap --no-merged-usr --arch=amd64 buster chroot https://deb.debian.org/debian
for i in dev dev/pts proc sys; do mount -o bind /$i chroot/$i; done
chroot chroot apt-get update -y
chroot chroot apt-get upgrade -y
chroot chroot apt-get dist-upgrade -y
chroot chroot apt-get install grub-pc-bin grub-efi -y
chroot chroot apt-get install linux-image-amd64 -y
chroot chroot apt-get install live-config live-boot -y
chroot chroot apt-get install xinit xserver-xorg -y
chroot chroot apt-get install emacs nano vim -y 
chroot chroot apt-get install build-essential -y
chroot chroot apt-get install meson -y
chroot chroot apt-get install npm -y
chroot chroot apt-get install pip -y
chroot chroot apt-get install python -y
chroot chroot apt-get install ruby -y
chroot chroot apt-get install php -y
chroot chroot apt-get install golang -y
chroot chroot apt-get install clisp -y

# Install lxde-gtk3
echo "deb https://raw.githubusercontent.com/lxde-gtk3/binary-packages/master stable main" > chroot/etc/apt/sources.list.d/lxde-gtk3.list
curl https://raw.githubusercontent.com/lxde-gtk3/binary-packages/master/dists/stable/Release.key | chroot chroot apt-key add -
chroot chroot apt-get update
chroot chroot apt-get install lxde-core -y

chroot chroot apt-get clean
rm -f chroot/root/.bash_history
rm -rf chroot/var/lib/apt/lists/*
find chroot/var/log/ -type f | xargs rm -f

cat > chroot/etc/os-release < EOF
NAME=procyberian
ID=toy
ID_LIKE=procyberian
BUILD_ID=procyberian
PRETTY_NAME="procyberian GNU/Linux"
HOME_URL="https://procyberian.masscollabs.com"
SUPPORT_URL="https://github.com/procyberian-linux"
BUG_REPORT_URL="https://github.com/procyberian-linux"
EOF

cat > chroot/etc/lsb-release < EOF
DISTRIB_ID=procyberian
DISTRIB_RELEASE=1
DISTRIB_CODENAME=toy
DISTRIB_DESCRIPTION="procyberian"
EOF

mkdir procyberian
umount -lf -R chroot/* 2>/dev/null
mksquashfs chroot filesystem.squashfs -comp gzip -wildcards
mkdir -p procyberian/live
mv filesystem.squashfs procyberian/live/filesystem.squashfs

cp -pf chroot/boot/initrd.img-* procyberian/live/initrd.img
cp -pf chroot/boot/vmlinuz-* procyberian/live/vmlinuz

mkdir -p procyberian/boot/grub/
echo 'menuentry "Start procyberian GNU/Linux 64-bit" --class procyberian {' > procyberian/boot/grub/grub.cfg
echo '    linux /live/vmlinuz boot=live live-config live-media-path=/live quiet splash --' >> procyberian/boot/grub/grub.cfg
echo '    initrd /live/initrd.img' >> procyberian/boot/grub/grub.cfg
echo '}' >> procyberian/boot/grub/grub.cfg

grub-mkrescue procyberian -o procyberian-gnu-linux.iso
