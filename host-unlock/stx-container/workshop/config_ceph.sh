source /etc/platform/openrc
 
echo ">>> Add OSDs to primary tier"
 
system host-disk-list controller-0
system host-disk-list controller-0 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-0 {}
system host-stor-list controller-0
 
