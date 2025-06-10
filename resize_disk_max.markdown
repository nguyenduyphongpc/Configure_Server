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
# ---

# Đặt biến cho đĩa và phân vùng
DISK="/dev/sda"
LVM_PARTITION="${DISK}2" # Thường là sda2 cho LVM
VG_NAME="centos"          # Thay đổi nếu VG của bạn có tên khác
LV_PATH="/dev/centos/root" # Thay đổi nếu LV của bạn có tên/đường dẫn khác

echo "Bắt đầu quá trình mở rộng đĩa..."
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

# 2. Mở rộng phân vùng LVM (nếu LVM nằm trên một phân vùng)
# Sử dụng growpart để mở rộng phân vùng. Cần cài đặt cloud-utils-growpart nếu chưa có.
if ! command -v growpart &> /dev/null; then
    echo "growpart không tìm thấy. Đang cài đặt cloud-utils-growpart..."
    yum install -y cloud-utils-growpart
    if [ $? -ne 0 ]; then
        echo "Lỗi: Không thể cài đặt cloud-utils-growpart. Vui lòng cài đặt thủ công và chạy lại script."
        exit 1
    fi
fi

echo "Đang mở rộng phân vùng ${LVM_PARTITION}..."
growpart ${DISK} ${LVM_PARTITION##*s} # ${LVM_PARTITION##*s} trích xuất số phân vùng (ví dụ: 2 từ /dev/sda2)
if [ $? -ne 0 ]; then
    echo "Lỗi: Không thể mở rộng phân vùng ${LVM_PARTITION}. Có thể cần khởi động lại hoặc kiểm tra thủ công."
    echo "Vui lòng kiểm tra bằng 'fdisk -l ${DISK}' và 'parted ${DISK} print'."
    exit 1
fi
echo "Đã mở rộng phân vùng ${LVM_PARTITION} thành công."
echo "-----------------------------------"

# 3. Mở rộng Physical Volume (PV)
echo "Đang mở rộng Physical Volume (PV) cho ${LVM_PARTITION}..."
pvresize ${LVM_PARTITION}
if [ $? -ne 0 ]; then
    echo "Lỗi: Không thể pvresize ${LVM_PARTITION}."
    exit 1
fi
echo "Thông tin PV sau khi resize:"
pvs
echo "Thông tin VG sau khi resize:"
vgs
echo "-----------------------------------"

# 4. Mở rộng Logical Volume (LV) để sử dụng toàn bộ không gian trống
echo "Đang mở rộng Logical Volume (LV) ${LV_PATH} để sử dụng toàn bộ không gian trống còn lại..."
lvextend -l +100%FREE ${LV_PATH} -r # Sử dụng -r để tự động resize filesystem XFS

if [ $? -ne 0 ]; then
    echo "Lỗi: Không thể lvextend ${LV_PATH}."
    # Nếu -r không hoạt động hoặc là EXT4, thử resize filesystem thủ công
    echo "Cố gắng resize filesystem thủ công..."
    FS_TYPE=$(df -T ${LV_PATH} | awk 'NR==2 {print $2}')
    if [ "${FS_TYPE}" == "xfs" ]; then
        echo "Đang chạy xfs_growfs trên ${LV_PATH}..."
        xfs_growfs ${LV_PATH}
    elif [ "${FS_TYPE}" == "ext4" ] || [ "${FS_TYPE}" == "ext3" ]; then
        echo "Đang chạy resize2fs trên ${LV_PATH}..."
        resize2fs ${LV_PATH}
    else
        echo "Lỗi: Không xác định được loại filesystem hoặc không hỗ trợ. Vui lòng resize thủ công."
    fi
    if [ $? -ne 0 ]; then
        echo "Lỗi: Không thể resize filesystem. Vui lòng kiểm tra và thực hiện thủ công."
        exit 1
    fi
fi
echo "Đã mở rộng LV và filesystem thành công."
echo "-----------------------------------"

# 5. Kiểm tra kết quả
echo "Kiểm tra dung lượng đĩa sau khi resize:"
df -h ${LV_PATH}
echo "lsblk -f sau khi hoàn tất:"
lsblk -f

echo "Quá trình mở rộng đĩa hoàn tất!"
```
