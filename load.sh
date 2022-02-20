#!/bin/bash

name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
cd $CIRRUS_WORKING_DIR/rom/$name_rom
mkdir -p ~/.config/rclone
echo "$rcloneconfig" > ~/.config/rclone/rclone.conf
rclone copy NFS:ccache/$name_rom/ccache.tar.gz $CIRRUS_WORKING_DIR/rom/$name_rom -P
time tar xf ccache.tar.gz
rm -rf ccache.tar.gz
cat > /etc/ccache.conf <<EOF
compression = true
run_second_cpp = true
depend_mode = true
direct_mode = true
file_clone = true
inode_cache = true
EOF
for t in ccache gcc g++ cc c++ clang clang++; do ln -vs /usr/bin/ccache /usr/local/bin/$t; done   
update-ccache-symlinks
dpkg -l ccache 
echo export PATH="/usr/lib/ccache:$PATH"
which ccache gcc g++ cc c++ clang clang++
