echo "Creating liveslack iso with custom modules"

STAGING_DIR=/tmp/slackwarelive_staging

rm -rf ${STAGING_DIR}

#mount -o loop /dev/sr0 /mnt/dvd && 
mkdir -p ${STAGING_DIR} && 
rsync -av -P --delete /mnt/dvd/ ${STAGING_DIR}/ && 
umount /mnt/dvd && 
rsync -av -P --delete  /home/oquendo/Downloads/mods_liveslack/ ${STAGING_DIR}/liveslak/addons/ &&
cd ${STAGING_DIR}/ &&
OUTPUT=/home/oquendo/  /home/oquendo/Downloads/liveslak/make_slackware_live.sh -G -v && 
echo "Done. Copy the iso where you need it."
