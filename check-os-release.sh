#!/bin/bash

# Function to check the OS version
check_os_version() {
    os_version=$(cat /etc/redhat-release)
    if [[ "$os_version" == *"Red Hat Enterprise Linux release 8.10"* ]]; then
        echo "OS version is RHEL 8.10."
    else
        echo "OS version is not RHEL 8.10."
    fi
}

# Function to check and modify permissions of /etc/cron.d
modify_permissions() {
    # Get the current permissions of /etc/cron.d
    current_permissions=$(stat -c "%a" /etc/cron.d)

    # Check if the permissions are 755
    if [ "$current_permissions" -eq 755 ]; then
        echo "Permissions are 755. Changing permissions..."
        # Change the permissions to remove read, write, and execute for others and group
        chmod og-rwx /etc/cron.d
        echo "Permissions changed to $(stat -c "%a" /etc/cron.d)"
    else
        echo "Permissions are not 755. No changes made."
    fi
}

# Main script execution
check_os_version
modify_permissions
