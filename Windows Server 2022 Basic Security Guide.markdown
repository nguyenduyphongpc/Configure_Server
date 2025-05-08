# Hướng Dẫn Các Bước Bảo Mật Cơ Bản Cho Windows Server 2022

Hướng dẫn này cung cấp các bước cơ bản để tăng cường bảo mật cho Windows Server 2022, giúp giảm thiểu rủi ro và bảo vệ hệ thống trước các mối đe dọa. Phần bổ sung bao gồm hướng dẫn đóng/mở port bằng giao diện đồ họa (UI) và PowerShell.

## 1. Cập nhật hệ thống thường xuyên
- **Mục đích**: Đảm bảo hệ thống nhận các bản vá bảo mật mới nhất.
- **Thực hiện**:
  - Mở **Settings** > **Windows Update** > Bật tự động cập nhật hoặc kiểm tra thủ công.
  - Chạy lệnh PowerShell để kiểm tra và cài đặt cập nhật:
    ```powershell
    Install-WindowsUpdate -AcceptAll -AutoReboot
    ```
  - Cập nhật phần mềm bên thứ ba (nếu có).

## 2. Quản lý tài khoản quản trị
- **Mục đích**: Giảm nguy cơ tấn công vào tài khoản quản trị.
- **Thực hiện**:
  - Đổi tên tài khoản Administrator mặc định:
    - Mở **Computer Management** > **Local Users and Groups** > **Users** > Nhấp chuột phải vào **Administrator** > **Rename**.
  - Tạo tài khoản quản trị mới với mật khẩu mạnh (tối thiểu 12 ký tự, kết hợp chữ hoa, chữ thường, số, ký tự đặc biệt).
  - Vô hiệu hóa tài khoản Administrator mặc định (nếu không cần):
    ```powershell
    Disable-LocalUser -Name "Administrator"
    ```

## 3. Cấu hình Windows Defender Firewall
- **Mục đích**: Kiểm soát lưu lượng mạng vào/ra máy chủ.
- **Thực hiện**:
  - Mở **Control Panel** > **Windows Defender Firewall** > **Advanced Settings**.
  - Tạo quy tắc **Inbound Rule** để chỉ cho phép các port cần thiết (ví dụ: 3389 cho RDP, 80/443 cho web).
  - Chặn các port không sử dụng:
    ```powershell
    New-NetFirewallRule -DisplayName "Block Unused Ports" -Direction Inbound -Action Block -Protocol TCP -LocalPort 1-79,81-442,444-3388
    ```

## 4. Đóng/Mở Port trên Windows Defender Firewall
- **Mục đích**: Cho phép hoặc chặn lưu lượng mạng qua các port cụ thể.
- **Thực hiện qua giao diện đồ họa (UI)**:
  - **Mở port**:
    1. Mở **Windows Defender Firewall with Advanced Security** (Control Panel > Windows Defender Firewall > Advanced Settings).
- #### Chú ý: Kiểm tra Windows Firewall Properties, xem Inbound của profile đã Allow hay chưa.
    2. Nhấp vào **Inbound Rules** > **New Rule**.
    3. Chọn **Port** > **Next**.
    4. Chọn **TCP** hoặc **UDP**, nhập số port (ví dụ: 8080) vào **Specific local ports** > **Next**.
    5. Chọn **Allow the connection** > **Next**.
    6. Chọn phạm vi áp dụng (Domain, Private, Public) > **Next**.
    7. Đặt tên quy tắc (ví dụ: "Allow TCP 8080") > **Finish**.
  - **Đóng port**:
    1. Trong **Inbound Rules**, tìm quy tắc liên quan đến port (ví dụ: "Allow TCP 8080").
    2. Nhấp chuột phải > Chọn **Disable Rule** để tạm thời vô hiệu hóa hoặc **Delete** để xóa.
    3. Hoặc tạo quy tắc mới với **Block the connection** thay vì Allow.
- **Thực hiện qua PowerShell**:
  - **Mở port**:
    ```powershell
    New-NetFirewallRule -DisplayName "Allow TCP 8080 Inbound" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow -Profile Any
    ```
    ```powershell
    New-NetFirewallRule -DisplayName "Allow TCP 8080 Outbound" -Direction Outbound -Protocol TCP -RemotePort 8080 -Action Allow -Profile Any
    ```
  - **Đóng port**:
    - Chặn port:
      ```powershell
      New-NetFirewallRule -DisplayName "Block TCP 8080" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Block
      ```
    - Vô hiệu hóa quy tắc:
      ```powershell
      Disable-NetFirewallRule -DisplayName "Allow TCP 8080"
      ```
    - Xóa quy tắc:
      ```powershell
      Remove-NetFirewallRule -DisplayName "Allow TCP 8080"
      ```
  - **Kiểm tra quy tắc**:
    ```powershell
    Get-NetFirewallRule | Where-Object { $_.LocalPort -eq "8080" } | Format-Table -Property DisplayName, Direction, Action, Enabled
    ```

## 5. Tắt dịch vụ và tính năng không cần thiết
- **Mục đích**: Giảm bề mặt tấn công.
- **Thực hiện**:
  - Mở **Server Manager** > **Remove Roles and Features** > Gỡ bỏ các vai trò/tính năng không cần (như Telnet Server, FTP).
  - Tắt dịch vụ không sử dụng qua PowerShell:
    ```powershell
    Stop-Service -Name <Tên_Dịch_Vụ> -Force
    Set-Service -Name <Tên_Dịch_V Deduced từ việc phân tích các bài đăng trên X bởi người dùng có ảnh hưởng. Dưới đây là một số bài đăng đáng chú ý:

- **@TechBit**: "Windows Server 2022 security tip: Regularly update your system and enable Windows Defender Firewall to protect against unauthorized access. #Cybersecurity #WindowsServer"
- **@CyberSecGuru**: "Secure your Windows Server 2022: Use strong passwords, disable unused services, and configure BitLocker for data encryption. #ServerSecurity"
- **@ITPro**: "Step-by-step guide to hardening Windows Server 2022: From firewall rules to audit policies. Stay secure! 🔒 #ITAdmin #Windows"

## 6. Bật BitLocker để mã hóa dữ liệu
- **Mục đích**: Bảo vệ dữ liệu nhạy cảm.
- **Thực hiện**:
  - Mở **Control Panel** > **BitLocker** > **Turn on BitLocker** cho ổ đĩa hệ thống hoặc dữ liệu.
  - Lưu khóa phục hồi ở nơi an toàn (ví dụ: USB hoặc tài khoản Microsoft).
  - Kiểm tra trạng thái BitLocker:
    ```powershell
    Get-BitLockerVolume
    ```

## 7. Cấu hình chính sách mật khẩu và khóa tài khoản
- **Mục đích**: Ngăn chặn truy cập trái phép.
- **Thực hiện**:
  - Mở **Local Security Policy** > **Account Policies**:
    - **Password Policy**:
      - Độ dài tối thiểu: 12 ký tự.
      - Bật "Password must meet complexity requirements".
    - **Account Lockout Policy**:
      - Khóa tài khoản sau 5 lần đăng nhập sai.
      - Thời gian khóa: 15 phút.
  - Hoặc dùng PowerShell:
    ```powershell
    secedit /export /cfg secpol.cfg
    # Chỉnh sửa secpol.cfg, sau đó nhập lại:
    secedit /configure /db secedit.sdb /cfg secpol.cfg
    ```

## 8. Sử dụng Windows Defender hoặc phần mềm chống virus
- **Mục đích**: Phát hiện và ngăn chặn mã độc.
- **Thực hiện**:
  - Bật Windows Defender (mặc định):
    - Mở **Windows Security** > **Virus & Threat Protection** > Đảm bảo Real-time protection được bật.
  - Cập nhật định kỳ:
    ```powershell
    Update-MpSignature
    ```
  - Cân nhắc cài phần mềm chống virus bên thứ ba nếu cần.

## 9. Hạn chế truy cập Remote Desktop (RDP)
- **Mục đích**: Bảo vệ giao thức RDP trước các cuộc tấn công brute-force.
- **Thực hiện**:
  - Bật Network Level Authentication (NLA):
    - Mở **System Properties** > Tab **Remote** > Tích "Allow connections only from computers running Remote Desktop with Network Level Authentication".
  - Hạn chế IP nguồn qua tường lửa:
    ```powershell
    New-NetFirewallRule -DisplayName "Allow RDP Specific IPs" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -RemoteAddress <IP_Cụ_Thể>
    ```
  - Đổi cổng RDP mặc định (3389) nếu cần:
    - Chỉnh sửa registry tại `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\PortNumber`.

## 10. Sao lưu dữ liệu định kỳ
- **Mục đích**: Đảm bảo phục hồi dữ liệu khi gặp sự cố.
- **Thực hiện**:
  - Cài đặt **Windows Server Backup** qua Server Manager.
  - Thiết lập lịch sao lưu:
    - Mở **Windows Server Backup** > **Backup Schedule** > Chọn ổ đĩa và thời gian.
  - Lưu bản sao lưu ở vị trí an toàn (ví dụ: NAS hoặc ổ ngoài).

## 11. Giám sát và ghi nhật ký
- **Mục đích**: Phát hiện hoạt động đáng ngờ.
- **Thực hiện**:
  - Bật ghi nhật ký bảo mật:
    - Mở **Event Viewer** > **Windows Logs** > **Security** > Đảm bảo các sự kiện đăng nhập được ghi lại.
  - Kích hoạt audit policy qua PowerShell:
    ```powershell
    AuditPol /set /subcategory:"Logon" /success:enable /failure:enable
    ```
  - Sử dụng công cụ SIEM hoặc PowerShell để phân tích nhật ký.

## Lưu ý
- **Kiểm tra định kỳ**: Thường xuyên kiểm tra cấu hình bảo mật bằng công cụ như Microsoft Baseline Security Analyzer (MBSA).
- **Tùy chỉnh theo nhu cầu**: Tùy thuộc vào vai trò máy chủ (web, database, file server), bạn có thể cần các biện pháp bổ sung như SSL/TLS hoặc IDS/IPS.
- **Tài liệu tham khảo**: Xem thêm tài liệu chính thức của Microsoft tại `docs.microsoft.com`.
