#!/bin/bash

# Variables
PROMETHEUS_VERSION="${PROMETHEUS_VERSION:-2.54.1}"
USER="${PROMETHEUS_USER:-prometheus}"
GROUP="${PROMETHEUS_GROUP:-prometheus}"
PROMETHEUS_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"
BINARY_DIR="/usr/local/bin"

# Download Prometheus
echo "Downloading Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Extract the files
echo "Extracting Prometheus..."
tar vxf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Create a system user for Prometheus
echo "Creating Prometheus user and group..."
sudo groupadd --system $GROUP
sudo useradd -s /sbin/nologin --system -g $GROUP $USER

# Create directories for Prometheus
echo "Creating directories..."
sudo mkdir -p $PROMETHEUS_DIR
sudo mkdir -p $DATA_DIR

# Move the binary files to /usr/local/bin
echo "Moving Prometheus binaries..."
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64/
sudo mv prometheus $BINARY_DIR/
sudo mv promtool $BINARY_DIR/

# Move the other necessary files to /etc/prometheus
echo "Moving configuration and console files..."
sudo mv consoles/ $PROMETHEUS_DIR/
sudo mv console_libraries/ $PROMETHEUS_DIR/
sudo mv prometheus.yml $PROMETHEUS_DIR/

# Set ownership
echo "Setting ownership..."
sudo chown -R $USER:$GROUP $BINARY_DIR/prometheus
sudo chown -R $USER:$GROUP $BINARY_DIR/promtool
sudo chown -R $USER:$GROUP $PROMETHEUS_DIR
sudo chown -R $USER:$GROUP $DATA_DIR

# Create Prometheus Systemd Service
echo "Creating Prometheus systemd service..."
sudo bash -c "cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$GROUP
Type=simple
ExecStart=$BINARY_DIR/prometheus \\
 --config.file $PROMETHEUS_DIR/prometheus.yml \\
 --storage.tsdb.path=$DATA_DIR \\
 --web.console.templates=$PROMETHEUS_DIR/consoles \\
 --web.console.libraries=$PROMETHEUS_DIR/console_libraries

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd to apply changes
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable Prometheus service
echo "Enabling Prometheus service..."
sudo systemctl enable prometheus

# Start Prometheus service
echo "Starting Prometheus service..."
sudo systemctl start prometheus

# Check Prometheus status
echo "Checking Prometheus status..."
sudo systemctl status prometheus
