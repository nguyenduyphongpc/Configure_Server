# Configure RAID Disk with Device Settings (LifeCycle Controller)
- **Reboot DELL Server** --> Trong khi Server đang khởi động lại nhấn **F2** để vào **System Setup**
- Tại giao diện **System Setup** --> Chọn **Device Settings**
- Tại giao diệ **Device Settings** --> Chọn **RAID Controller...** --> **Main Menu** --> **Create Virtual Disk** --> Tại **Select RAID Level ta chọn RAID theo nhu cầu sử dụng(RAID 0, **RAID 1**, RAID 5, RAID 6, RAID 10)** --> Tiếp đến ta chọn **Select Physical Disk**
    - RAID nên sử dụng các ổ cứng có dung lượng bằng nhau.

    - Việc sử dụng RAID sẽ tốn nhiều ổ cứng hơn so với không sử dụng, nhưng đổi lại dữ liệu sẽ được bảo vệ tốt hơn.

    - RAID có thể hoạt động trên nhiều hệ điều hành như Windows 98, Windows 2000, Windows XP, Windows 10, Windows Server 2016, MAC OS X, Linux,...

    - RAID 0 sẽ có dung lượng bằng tổng dung lượng của các ổ cứng.

    - RAID 1 sẽ duy trì dung lượng của một ổ cứng.

    - RAID 5 sẽ có dung lượng nhỏ hơn một ổ cứng (ví dụ: sử dụng 5 ổ cứng RAID 5 sẽ có dung lượng tương đương với 4 ổ cứng).

    - RAID 6 sẽ có dung lượng nhỏ hơn hai ổ cứng (ví dụ: sử dụng 5 ổ cứng RAID 6 sẽ có dung lượng tương đương với 3 ổ cứng).

    - RAID 10 chỉ có thể được tạo ra khi sử dụng số lượng ổ cứng chẵn và tối thiểu là bốn ổ cứng. Dung lượng sử dụng của RAID 10 bằng một nửa tổng dung lượng của các ổ cứng sử dụng (ví dụ: sử dụng 10 ổ cứng RAID 10 sẽ có dung lượng tương đương với 5 ổ cứng).
- Tại giao diện **Select Physical Disk** --> **Select Media Type** chọn 1 trong 2 type **SSD** hoặc **HDD** --> Trong **Choose unconfigured physical disks** chọn các ổ cứng mà bạn muốn RAID --> **Apply Change** --> **OK**
- Tại phần **CONFIGURE VIRTUAL DISK PARAMETERS** --> **Create Virtual Disk** --> **Confirm --> Yes**
