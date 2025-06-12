# Setup Docker and n8n with PostgreSQL on Ubuntu Server 22.04

This guide provides step-by-step instructions to install Docker, set up an n8n service with Docker Compose using PostgreSQL as the database, configure it to run on `localhost:5678` with the `Asia/Ho_Chi_Minh` timezone, and ensure the service auto-starts on system boot. The setup is designed for local access only.

## Prerequisites
- Ubuntu Server 22.04
- A user with sudo privileges
- Internet access

---

## 1. Install Docker

1. **Update the system**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install required packages**:
   ```bash
   sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
   ```

3. **Add Docker’s official GPG key**:
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```

4. **Add Docker repository**:
   ```bash
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

5. **Install Docker**:
   ```bash
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
   ```

6. **Start and enable Docker service**:
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo systemctl enable docker.socket
   ```

7. **Verify Docker installation**:
   ```bash
   docker --version
   sudo docker run hello-world
   ```

8. **(Optional) Allow non-root user to run Docker**:
   ```bash
   sudo usermod -aG docker $USER
   ```
   Log out and back in for changes to take effect.

---

## 2. Set Up n8n with PostgreSQL and Docker Compose

1. **Create a project directory**:
   ```bash
   mkdir ~/n8n && cd ~/n8n
   ```

2. **Create `docker-compose.yml`**:
   ```bash
   nano docker-compose.yml
   ```
   Paste the following configuration:
   ```yaml
   version: '3.9'
   services:
     n8n:
       image: docker.n8n.io/n8nio/n8n:latest
       container_name: n8n
       ports:
         - "5678:5678"
       environment:
         - N8N_HOST=localhost
         - N8N_PORT=5678
         - N8N_PROTOCOL=http
         - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
         - TZ=Asia/Ho_Chi_Minh
         - N8N_SECURE_COOKIE=false
         - DB_TYPE=postgresdb
         - DB_POSTGRESDB_HOST=n8n-db
         - DB_POSTGRESDB_PORT=5432
         - DB_POSTGRESDB_DATABASE=n8n
         - DB_POSTGRESDB_USER=n8nuser
         - DB_POSTGRESDB_PASSWORD=n8npass
       volumes:
         - n8n_data:/home/node/.n8n
       restart: unless-stopped
       depends_on:
         - db
     db:
       image: postgres:17
       container_name: n8n-db
       environment:
         - POSTGRES_DB=n8n
         - POSTGRES_USER=n8nuser
         - POSTGRES_PASSWORD=n8npass
       volumes:
         - pg_data:/var/lib/postgresql/data
       restart: on-failure:5
   volumes:
     n8n_data:
       name: n8n_data
     pg_data:
       name: pg_data
   ```
   Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

3. **(Optional) Set up basic authentication**:
   Create an `.env` file for secure credentials:
   ```bash
   nano .env
   ```
   Add:
   ```
   N8N_BASIC_AUTH_ACTIVE=true
   N8N_BASIC_AUTH_USER=admin
   N8N_BASIC_AUTH_PASSWORD=securepassword
   ```
   Save and exit. Update `docker-compose.yml` to include:
   ```yaml
       env_file:
         - .env
   ```
   under the `n8n` service.

4. **Start the n8n and PostgreSQL services**:
   ```bash
   docker compose up -d
   ```

5. **Access n8n**:
   - Open a browser on the server (e.g., via a local browser like Lynx or a remote browser if accessing via SSH).
   - Navigate to `http://localhost:5678`.
   - Log in with credentials from `.env` (if set) or set up an admin account.

---

## 3. Ensure n8n Auto-Starts on Boot

1. **Verify Docker auto-starts**:
   ```bash
   systemctl is-enabled docker
   ```
   If `disabled`, enable it:
   ```bash
   sudo systemctl enable docker
   sudo systemctl enable docker.socket
   ```

2. **Confirm restart policy**:
   - The `restart: unless-stopped` in `n8n` service ensures it restarts on boot unless explicitly stopped.
   - The `restart: on-failure:5` in `db` service ensures the PostgreSQL container restarts up to 5 times on failure.

3. **Test auto-start**:
   Reboot the server:
   ```bash
   sudo reboot
   ```
   After reboot, check if n8n and PostgreSQL are running:
   ```bash
   docker ps
   ```
   Access `http://localhost:5678` to confirm.

4. **(Optional) Create a Systemd service for Docker Compose**:
   ```bash
   sudo nano /etc/systemd/system/n8n.service
   ```
   Add:
   ```ini
   [Unit]
   Description=n8n Docker Compose Service
   Requires=docker.service
   After=docker.service

   [Service]
   Type=oneshot
   RemainAfterExit=yes
   WorkingDirectory=/home/<your-username>/n8n
   ExecStart=/usr/bin/docker compose up -d
   ExecStop=/usr/bin/docker compose down
   TimeoutStartSec=0

   [Install]
   WantedBy=multi-user.target
   ```
   Replace `<your-username>` with your username (check with `whoami`). Save and exit.
   - Enable and start:
     ```bash
     sudo systemctl enable n8n.service
     sudo systemctl start n8n.service
     ```

---

## 4. Verify and Troubleshoot

1. **Check n8n and PostgreSQL status**:
   ```bash
   docker logs n8n
   docker logs n8n-db
   ```

2. **Verify timezone**:
   ```bash
   docker exec -it n8n date
   ```
   Should show `Asia/Ho_Chi_Minh` (UTC+07:00, e.g., 1:03 AM, June 13, 2025).

3. **Check port 5678**:
   ```bash
   sudo netstat -tuln | grep 5678
   ```
   If not open, allow it:
   ```bash
   sudo ufw allow 5678
   ```

4. **Fix permissions** (if needed):
   ```bash
   sudo chown -R 1000:1000 ~/n8n
   ```

---

## Notes
- **Timezone**: Configured for `Asia/Ho_Chi_Minh` (UTC+07:00).
- **Database**: PostgreSQL is used for scalability, with data persisted in the `pg_data` volume.
- **Access**: Only available on `http://localhost:5678` from the server. For remote access, configure SSH tunneling or a reverse proxy.
- **Security**: Use strong credentials in `.env` for production. Avoid exposing n8n publicly without HTTPS.
- **Updates**: To update n8n or PostgreSQL:
  ```bash
  docker compose pull
  docker compose up -d
  ```

Your n8n instance with PostgreSQL is now running on `http://localhost:5678` and auto-starts on boot!