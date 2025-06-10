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
```shell
#!/bin/bash

# --- Cảnh báo quan trọng ---
# SCRIPT NÀY SẼ THỰC HIỆN CÁC THAY ĐỔI ĐỐI VỚI HỆ THỐNG PHÂN VÙNG.
# HÃY SAO LƯU DỮ LIỆU CỦA BẠN TRƯỚC KHI CHẠY SCRIPT NÀY!
# CHẠY SCRIPT NÀY TRÊN MÔI TRƯỜNG MÔ PHỎNG HOẶC MÁY ẢO ĐỂ ĐẢM BẢO AN TOÀN TRƯỚC KHI ÁP DỤNG TRÊN MÔI TRƯỜNG THẬT.
# RESIZE PHÂN VÙNG GỐC ĐANG HOẠT ĐỘNG CÓ THỂ CỰC KỲ RỦI RO.
# NẾU CÓ THỂ, HÃY KHỞI ĐỘNG TỪ MỘT LIVE CD/USB ĐỂ THỰC HIỆN VIỆC NÀY.
# ---

# Đặt biến cho đĩa và phân vùng
DISK="/dev/sda"
TARGET_PARTITION="${DISK}1" # Thay đổi nếu phân vùng của bạn là sda2, sda3, v.v.
MOUNT_POINT="/"             # Thay đổi nếu mount point của phân vùng là khác (ví dụ: /var, /opt)

echo "Bắt đầu quá trình mở rộng đĩa cho phân vùng truyền thống..."
echo "Kiểm tra tình trạng đĩa và phân vùng hiện tại:"
lsblk -f
echo "-----------------------------------"

# 1. Rescan đĩa để nhận diện dung lượng mới
echo "Đang rescan đĩa ${DISK} để nhận diện dung lượng mới..."
echo 1 > /sys/class/block/${DISK##*/}/device/rescan 2>/dev/null || true
sleep 2 # Đợi một chút để hệ thống cập nhật
echo "Kiểm tra dung lượng đĩa sau khi rescan:"
fdisk -l ${DISK}
echo "-----------------------------------"

# 2. Mở rộng phân vùng sử dụng growpart
# Cần cài đặt cloud-utils-growpart nếu chưa có.
if ! command -v growpart &> /dev/null; then
    echo "growpart không tìm thấy. Đang cài đặt cloud-utils-growpart..."
    yum install -y cloud-utils-growpart
    if [ $? -ne 0 ]; then
        echo "Lỗi: Không thể cài đặt cloud-utils-growpart. Vui lòng cài đặt thủ công và chạy lại script."
        exit 1
    fi
fi

echo "Đang mở rộng phân vùng ${TARGET_PARTITION}..."
# ${TARGET_PARTITION##*s} trích xuất số phân vùng (ví dụ: 1 từ /dev/sda1)
growpart ${DISK} ${TARGET_PARTITION##*s}
if [ $? -ne 0 ]; then
    echo "Lỗi: Không thể mở rộng phân vùng ${TARGET_PARTITION}."
    echo "Có thể cần khởi động lại để kernel nhận diện thay đổi hoặc kiểm tra thủ công với 'fdisk -l ${DISK}'."
    exit 1
fi
echo "Đã mở rộng phân vùng ${TARGET_PARTITION} thành công."
echo "-----------------------------------"

# 3. Mở rộng Filesystem
echo "Đang mở rộng filesystem trên ${TARGET_PARTITION}..."
FS_TYPE=$(df -T ${MOUNT_POINT} | awk 'NR==2 {print $2}')

if [ "${FS_TYPE}" == "xfs" ]; then
    echo "Phát hiện filesystem XFS. Đang chạy xfs_growfs trên ${MOUNT_POINT}..."
    xfs_growfs ${MOUNT_POINT}
elif [ "${FS_TYPE}" == "ext4" ] || [ "${FS_TYPE}" == "ext3" ]; then
    echo "Phát hiện filesystem EXT4/EXT3. Đang chạy resize2fs trên ${TARGET_PARTITION}..."
    resize2fs ${TARGET_PARTITION}
else
    echo "Lỗi: Không xác định được loại filesystem hoặc không hỗ trợ tự động resize. Vui lòng resize thủ công."
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "Lỗi: Không thể resize filesystem. Vui lòng kiểm tra và thực hiện thủ công."
    exit 1
fi
echo "Đã mở rộng filesystem thành công."
echo "-----------------------------------"

# 4. Kiểm tra kết quả
echo "Kiểm tra dung lượng đĩa sau khi resize:"
df -h ${MOUNT_POINT}
echo "lsblk -f sau khi hoàn tất:"
lsblk -f

echo "Quá trình mở rộng đĩa hoàn tất!"
```
