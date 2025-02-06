#!/bin/bash

# Update package lists and install prerequisites
echo "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget

# Import the Grafana GPG key
echo "Importing Grafana GPG key..."
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add the Grafana repository (stable)
echo "Adding stable Grafana repository..."
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Add the Grafana repository (beta)
# echo "Adding beta Grafana repository..."
# echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update package lists after adding the repository
echo "Updating package lists..."
sudo apt-get update

# Install Grafana OSS
echo "Installing Grafana OSS..."
sudo apt-get install -y grafana

# Start the Grafana service using systemd
echo "Starting Grafana server..."
sudo systemctl daemon-reload
sudo systemctl start grafana-server

# Verify the Grafana service is running
echo "Checking Grafana service status..."
sudo systemctl status grafana-server

# Enable Grafana server to start at boot
echo "Enabling Grafana to start at boot..."
sudo systemctl enable grafana-server.service

echo "Grafana installation and configuration completed!"
