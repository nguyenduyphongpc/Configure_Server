#!/bin/bash
MOUNT_DIR_BACKUP="/mnt/windows_backup"
MOUNT_CMD_BAKCUP="sudo mount -t cifs //192.168.50.160/Backup $MOUNT_DIR_BACKUP -o username=backupuser,password=N40Y3u@n4"
MOUNT_BACKUP_FLAG="$MOUNT_DIR_BACKUP/flag"

while true; do
  echo "🔁 Checking mount and restarting containers..."
  if [ ! -d "$MOUNT_DIR_BACKUP" ]; then
    echo "📁 Creating mount directory at $MOUNT_DIR_BACKUP"
    sudo mkdir -p "$MOUNT_DIR_BACKUP" || {
      echo "❌ Failed to create $MOUNT_DIR_BACKUP"
      continue
    }
  fi
  
  if [ ! -e "$MOUNT_BACKUP_FLAG" ]; then
    echo "🔗 Mounting CIFS share..."
    $MOUNT_CMD_BAKCUP || {
      echo "❌ Failed to mount share"
      continue
    }
  else
    echo "✅ Mount already exists"
  fi


  echo "🕑 Sleeping before next iteration..."
  sleep 2
done
