#!/bin/bash

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
