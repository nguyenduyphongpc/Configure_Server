# Mở rộng phân vùng / lên max
```powershell
#!/bin/bash
echo "Mo rong phan vung / len max"
parted /dev/sda resizepart 4 100%
pvresize /dev/sda4
lvextend -l +100%FREE /dev/mapper/vg0-lv--0
resize2fs /dev/mapper/vg0-lv--0
echo "Hoan Thanh"
```