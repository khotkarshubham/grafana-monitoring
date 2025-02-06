#!/bin/bash

# Variables
BLACKBOX_VERSION="0.25.0"
BLACKBOX_USER="blackbox"
DOWNLOAD_URL="https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz"
TAR_FILE="blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz"
EXTRACTED_DIR="blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64"
CONFIG_DIR="/etc/blackbox"
CONFIG_FILE="$CONFIG_DIR/blackbox.yml"
SERVICE_FILE="/etc/systemd/system/blackbox.service"

# Step 1: Add blackbox user
echo "Creating blackbox user..."
sudo useradd --no-create-home $BLACKBOX_USER

# Step 2: Download and extract Blackbox binary
echo "Downloading Blackbox Exporter version ${BLACKBOX_VERSION}..."
wget $DOWNLOAD_URL

echo "Extracting Blackbox Exporter..."
tar -xvf $TAR_FILE

# Step 3: Create configuration directory
echo "Creating configuration directory..."
sudo mkdir -p $CONFIG_DIR

# Step 4: Copy files to appropriate locations
echo "Copying binaries and configuration files..."
sudo cp $EXTRACTED_DIR/blackbox_exporter /usr/local/bin/
sudo cp $EXTRACTED_DIR/blackbox.yml $CONFIG_DIR/

# Step 5: Set permissions for blackbox user
echo "Setting permissions for blackbox user..."
sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter
sudo chown -R blackbox:blackbox $CONFIG_DIR/*

# Step 6: Create systemd service file
echo "Creating systemd service file..."
cat <<EOL | sudo tee $SERVICE_FILE
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=blackbox
Group=blackbox
Type=simple
ExecStart=/usr/local/bin/blackbox_exporter --config.file=/etc/blackbox/blackbox.yml --web.listen-address="0.0.0.0:9115"

[Install]
WantedBy=multi-user.target
EOL

# Step 7: Reload systemd, enable and start the Blackbox service
echo "Reloading systemd and starting Blackbox service..."
sudo systemctl daemon-reload
sudo systemctl enable blackbox
sudo systemctl start blackbox
sudo systemctl status blackbox

# Step 8: Cleanup
echo "Cleaning up..."
rm -rf $TAR_FILE $EXTRACTED_DIR

echo "Blackbox Exporter installation and setup complete!"
