#!/bin/bash

device=$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
ROM_OUT=$CIRRUS_WORKING_DIR/rom/$name_rom/out/target/product/$device/$name_rom*.zip
cd $CIRRUS_WORKING_DIR

function upload_rom() {
   rclone copy --drive-chunk-size 256M --stats 1s $ROM_OUT NFS:rom/$name_rom -P
}

function upload_ccache() {
   com ()
   {
     tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
   }
   time com ccache 1
   rclone copy --drive-chunk-size 256M --stats 1s ccache.tar.gz NFS:ccache/$name_rom -P
   rm -rf ccache.tar.gz
}

function checkrom() {
    curl -s https://api.telegram.org/bot$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="Building Rom $name_rom [❌].."
    echo Upload ccache only..
    upload_ccache
    exit 1
}

if ! [ -a "$ROM_OUT" ]; then
    checkrom
    kill %1
fi



curl -s https://api.telegram.org/bot$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="Building Rom $name_rom [✔️].."
upload_rom
curl -s https://api.telegram.org/bot$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="Link : https://needforspeed.projek.workers.dev/rom/$name_rom/$(cd $CIRRUS_WORKING_DIR/rom/$name_rom/out/target/product/$device && ls $name_rom*.zip)"
upload_ccache
