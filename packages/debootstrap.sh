#!/bin/bash
#debootstrap install from source (for non-debian systems)
set -e
git clone https://salsa.debian.org/installer-team/debootstrap debootstrap
cd debootstrap
wget -O 0002-remove-merged-user.patch https://gitlab.com/sulinos/repositories/SulinRepository/-/raw/master/system/devel/debootstrap/files/0002-remove-merged-user.patch
wget -O 0001-remove-dpkg-support.patch https://gitlab.com/sulinos/repositories/SulinRepository/-/raw/master/system/devel/debootstrap/files/0001-remove-dpkg-support.patch
patch -N -p1 -i 0001-remove-dpkg-support.patch 
patch -N -p1 -i 0002-remove-merged-user.patch
make install
