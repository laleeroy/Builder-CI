#sync rom
repo init --depth=1 --no-repo-verify -u git://github.com/LineageOS/android.git -b lineage-15.1 -g default,-mips,-darwin,-notdefault
git clone https://github.com/nhAsif/local_manifest.git --depth 1 -b los15 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync

# build rom
source build/envsetup.sh
lunch lineage_rosy-userdebug
export TZ=Asia/Dhaka
export BUILD_USERNAME=rosy
export BUILD_HOSTNAME=userdebug
curl -s https://api.telegram.org/bot$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="$(echo "${var_cache_report_config}")"
make bacon -j10 &
sleep 95m
kill %1 


# upload rom
rclone copy out/target/product/$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)/*.zip cirrus:$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1) -P
