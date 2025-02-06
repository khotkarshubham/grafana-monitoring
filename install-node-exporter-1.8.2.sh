#!/bin/bash

# Step 1: Download Node Exporter
echo "Downloading Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Step 2: Extract Node Exporter
echo "Extracting Node Exporter..."
sudo tar xzf node_exporter-1.8.2.linux-amd64.tar.gz

# Step 3: Remove the downloaded tar file
echo "Removing the tar file..."
sudo rm -rf node_exporter-1.8.2.linux-amd64.tar.gz

# Step 4: Move files to /etc/node_exporter
echo "Moving Node Exporter to /etc/node_exporter..."
sudo mv node_exporter-1.8.2.linux-amd64 /etc/node_exporter

# Step 5: Create the systemd service file
echo "Creating Node Exporter service..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOL
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/etc/node_exporter/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Step 6: Reload systemd, enable and start Node Exporter service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling Node Exporter service..."
sudo systemctl enable node_exporter

echo "Starting Node Exporter service..."
sudo systemctl restart node_exporter

# Step 7: Check if Node Exporter is running
echo "Checking Node Exporter status..."
sudo systemctl status node_exporter
