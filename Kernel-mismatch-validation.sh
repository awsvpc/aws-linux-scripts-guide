#!/bin/bash

# Function to get the current running kernel version
get_running_kernel_version() {
  uname -r
}

# Function to get the latest installed kernel version
get_latest_installed_kernel_version() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "amzn" ]]; then
      rpm -q --last kernel | head -n 1 | awk '{print $1}'
    elif [[ "$ID" == "rhel" ]] || [[ "$ID" == "centos" ]]; then
      rpm -q --last kernel | head -n 1 | awk '{print $1}'
    else
      echo "Unsupported OS"
      exit 1
    fi
  else
    echo "Cannot determine OS"
    exit 1
  fi
}

# Get the current running kernel version
running_kernel=$(get_running_kernel_version)

# Get the latest installed kernel version
latest_installed_kernel=$(get_latest_installed_kernel_version)

# Remove 'kernel-' prefix if present
latest_installed_kernel=${latest_installed_kernel#kernel-}

# Compare the versions
if [ "$running_kernel" != "$latest_installed_kernel" ]; then
  echo "found kernel mismatch"
else
  echo "Kernel versions match"
fi
