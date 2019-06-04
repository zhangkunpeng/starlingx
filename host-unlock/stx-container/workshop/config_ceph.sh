source /etc/platform/openrc
echo ">>> Enable primary Ceph backend"
system storage-backend-add ceph --confirmed
 
echo ">>> Wait for primary ceph backend to be configured"
echo ">>> This step really takes a long time"
while [ $(system storage-backend-list | awk '/ceph-store/{print $8}') != 'configured' ]; do echo 'Waiting for ceph..'; sleep 5; done
 
echo ">>> Ceph health"
ceph -s
 
echo ">>> Add OSDs to primary tier"
 
system host-disk-list controller-0
system host-disk-list controller-0 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-0 {}
system host-stor-list controller-0
 
echo ">>> ceph osd tree"
ceph osd tree