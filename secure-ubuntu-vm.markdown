# Cấu hình bảo mật cho VM Ubuntu Desktop

## Mô tả
Script này tự động hóa việc thiết lập các biện pháp bảo mật cơ bản cho máy ảo Ubuntu Desktop, bao gồm:
- Cài đặt và cấu hình cập nhật tự động lúc 0h hàng ngày với `unattended-upgrades`.
- Đổi cổng SSH sang 3333, vô hiệu hóa đăng nhập root, và yêu cầu sử dụng khóa SSH.
- Cấu hình tường lửa UFW để cho phép cổng 3333 và chặn cổng 22.
- Cài đặt và cấu hình Fail2Ban để bảo vệ SSH khỏi các cuộc tấn công brute-force.

## Yêu cầu
- Chạy với quyền `sudo`.
- Đã thiết lập khóa SSH và sao chép khóa công khai vào VM trước khi chạy để tránh mất kết nối SSH.
- Hệ điều hành: Ubuntu 22.04.

## Nội dung script

```bash
#!/bin/bash
echo "Bắt đầu cấu hình bảo mật cho VM Ubuntu Desktop..."

# 1. Cài đặt và cấu hình unattended-upgrades
echo "Cấu hình cập nhật tự động lúc 0h hàng ngày..."
sudo apt update
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee /etc/apt/apt.conf.d/10periodic
echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
echo 'APT::Periodic::AutocleanInterval "7";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
echo '0 0 * * * /usr/bin/unattended-upgrades --verbose' | sudo crontab -

# 2. Cấu hình SSH
echo "Đổi cổng SSH và vô hiệu hóa đăng nhập root..."
sudo apt install openssh-server -y
sudo sed -i 's/#Port 22/Port 3333/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i "/AllowUsers/d" /etc/ssh/sshd_config
echo "AllowUsers $USER" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh

# 3. Cấu hình UFW cho SSH
echo "Cấu hình tường lửa..."
sudo apt install ufw -y
sudo ufw allow 3333
sudo ufw deny 22
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# 4. Cài đặt và cấu hình Fail2Ban
echo "Cài đặt Fail2Ban..."
sudo apt install fail2ban -y
# Sao lưu file cấu hình hiện tại nếu tồn tại
[ -f /etc/fail2ban/jail.local ] && sudo mv /etc/fail2ban/jail.local /etc/fail2ban/jail.local.bak
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# Kiểm tra xem section [sshd] đã tồn tại chưa, nếu không thì thêm
if ! grep -q "\[sshd\]" /etc/fail2ban/jail.local; then
  cat <<EOL | sudo tee -a /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 3333
maxretry = 5
bantime = 3600
findtime = 600
EOL
else
  # Cập nhật section [sshd] nếu đã tồn tại
  sudo sed -i '/\[sshd\]/,/^\[/ s/port.*/port = 3333/' /etc/fail2ban/jail.local
  sudo sed -i '/\[sshd\]/,/^\[/ s/enabled.*/enabled = true/' /etc/fail2ban/jail.local
  sudo sed -i '/\[sshd\]/,/^\[/ s/maxretry.*/maxretry = 5/' /etc/fail2ban/jail.local
  sudo sed -i '/\[sshd\]/,/^\[/ s/bantime.*/bantime = 3600/' /etc/fail2ban/jail.local
  sudo sed -i '/\[sshd\]/,/^\[/ s/findtime.*/findtime = 600/' /etc/fail2ban/jail.local
fi
# Kiểm tra cú pháp cấu hình Fail2Ban
sudo fail2ban-client -t
if [ $? -eq 0 ]; then
  sudo systemctl restart fail2ban
  sudo systemctl enable fail2ban
else
  echo "Lỗi cấu hình Fail2Ban, kiểm tra /etc/fail2ban/jail.local"
  exit 1
fi

echo "Hoàn thành cấu hình bảo mật!"
```

## Hướng dẫn sử dụng
1. Lưu script vào file, ví dụ: `secure-ubuntu-vm.sh`.
   ```bash
   nano secure-ubuntu-vm.sh
   ```
2. Phân quyền thực thi:
   ```bash
   chmod +x secure-ubuntu-vm.sh
   ```
3. Chạy script với quyền `sudo`:
   ```bash
   sudo ./secure-ubuntu-vm.sh
   ```
4. **Trước khi chạy**:
   - Tạo và sao chép khóa SSH để đăng nhập qua cổng 3333:
     ```bash
     ssh-keygen -t rsa -b 4096
     ssh-copy-id -i ~/.ssh/id_rsa.pub itadm@<IP_của_VM> -p 3333
     ```
   - Kiểm tra kết nối SSH:
     ```bash
     ssh -p 3333 itadm@<IP_của_VM>
     ```

## Kiểm tra sau khi chạy
- **Cập nhật tự động**:
  ```bash
  sudo crontab -l
  sudo cat /etc/apt/apt.conf.d/10periodic
  ```
- **SSH**:
  ```bash
  sudo cat /etc/ssh/sshd_config | grep -E "Port|PermitRootLogin|PasswordAuthentication|AllowUsers"
  sudo systemctl status ssh
  ```
- **UFW**:
  ```bash
  sudo ufw status
  ```
- **Fail2Ban**:
  ```bash
  sudo systemctl status fail2ban
  sudo fail2ban-client status sshd
  ```

## Lưu ý
- Sao lưu dữ liệu trước khi chạy script.
- Nếu gặp lỗi Fail2Ban, kiểm tra `/var/log/fail2ban.log` và `/etc/fail2ban/jail.local`.
- Đảm bảo cổng 3333 được mở trên ESXi hoặc mạng.
