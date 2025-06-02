#!/bin/bash

BASE_DIR="/home/adm1n"
PROJECTS=(
  "faces_queue_1"
  "vehicle"
  "hatqueue_1"
  "queue_clothes_0"
  "vehicle_queue"
  "human"
  "vehicle_queue_video"
  "search"
  "facesengine"
  "api-faces-x-3456498/BEServer"
)

MOUNT_DIR="/mnt/mainpool"
MOUNT_FLAG="$MOUNT_DIR/flag"
MOUNT_CMD="sudo mount -t cifs //192.168.50.160/pool200tb $MOUNT_DIR -o username=sysadmin,password=QxcPnb8389$"

while true; do
  echo "🔁 Checking mount and restarting containers..."

  # Section 1: Ensure /mnt/mainpool exists
  if [ ! -d "$MOUNT_DIR" ]; then
    echo "📁 Creating mount directory at $MOUNT_DIR"
    sudo mkdir -p "$MOUNT_DIR" || {
      echo "❌ Failed to create $MOUNT_DIR"
      continue
    }
  fi

  # Section 2: Check if mounted by checking flag file
  if [ ! -e "$MOUNT_FLAG" ]; then
    echo "🔗 Mounting CIFS share..."
    $MOUNT_CMD || {
      echo "❌ Failed to mount share"
      continue
    }
    for DIR in "${PROJECTS[@]}"; do
        PROJECT_PATH="$BASE_DIR/$DIR"
        COMPOSE_FILE="$PROJECT_PATH/docker-compose.yml"
        cd "$PROJECT_PATH" || {
            echo "❌ Failed to change directory to $PROJECT_PATH"
            continue
        }
        docker compose down
        docker compose up -d
        echo "✅ Done: $DIR"
    done
  else
    echo "✅ Mount already exists"
  fi
  


  echo "🕑 Sleeping before next iteration..."
  sleep 2
done
