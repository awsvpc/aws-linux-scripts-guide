#!/bin/bash

# Function to get Splunk forwarder version
get_splunk_version() {
    local version=$( /opt/splunkforwarder/bin/splunk --version | grep -oP 'Splunk Forwarder \K\d+\.\d+\.\d+' )
    echo "$version"
}

# Function to check Splunk forwarder service status
get_service_status() {
    local status=$( systemctl is-active splunk )
    echo "$status"
}

# Function to upgrade Splunk forwarder
upgrade_splunk_forwarder() {
    # Create user and group if not exists
    if ! id -u splunkfwd &>/dev/null; then
        echo "Creating user and group for Splunk forwarder..."
        sudo groupadd splunkfwd
        sudo useradd -r -s /sbin/nologin -g splunkfwd splunkfwd
    fi

    # Download and install RPM
    echo "Downloading Splunk forwarder RPM..."
    curl -o splunkapp.rpm http://mylocaldomain.com/binaries/splunkapp.rpm
    echo "Installing Splunk forwarder..."
    sudo rpm -ivh splunkapp.rpm

    # Check installation status
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "Splunk forwarder updated. Exit code 0"
    else
        echo "Failed to install Splunk forwarder. Exit code 1"
        exit 1
    fi
}

# Function to start Splunk forwarder service
start_splunk_service() {
    echo "Starting Splunk forwarder service..."
    sudo systemctl start splunk
}

# Main script
current_version=$(get_splunk_version)
service_status=$(get_service_status)

if [[ $current_version == "9.2.1" && $service_status == "active" ]]; then
    echo "Splunk forwarder already up to date. Exit code 0"
else
    upgrade_splunk_forwarder

    # Start Splunk forwarder service if not running
    if [ $service_status != "active" ]; then
        start_splunk_service
        sleep 10  # Wait for service to start
        timeout=300  # 5 minutes timeout
        elapsed_time=0

        # Check service status every 10 seconds until timeout
        while [ "$(get_service_status)" != "active" ] && [ $elapsed_time -lt $timeout ]; do
            sleep 10
            elapsed_time=$((elapsed_time + 10))
        done

        if [ "$(get_service_status)" == "active" ]; then
            echo "Splunk forwarder service started successfully."
        else
            echo "Failed to start Splunk forwarder service within timeout. Exiting..."
            exit 1
        fi
    fi
fi
