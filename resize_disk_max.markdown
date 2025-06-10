# Mở rộng phân vùng / lên max 
# Ubuntu
```shell
#!/bin/bash
echo "Mo rong phan vung / len max"
parted /dev/sda resizepart 4 100%
pvresize /dev/sda4
lvextend -l +100%FREE /dev/mapper/vg0-lv--0
resize2fs /dev/mapper/vg0-lv--0
echo "Hoan Thanh"
```
# CentOs7
[link](https://tailieu.tgs.com.vn/mo-rong-dung-luong-o-cung-cua-may-ao-centos-tren-vmware/)
