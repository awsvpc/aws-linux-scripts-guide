#!/bin/bash

# Function to calculate the gateway IP address
calculate_gateway_ip() {
    local subnet_cidr=$1
    local subnet=${subnet_cidr%/*}
    local cidr=${subnet_cidr#*/}
    
    local gateway=""
    local prefixlen=$((128 - cidr))
    local num_zeros=$((prefixlen / 4))
    
    # Get the network portion of the subnet
    local network=$(echo $subnet | cut -d: -f1-4)
    
    # Convert the hex digits to binary
    local binary_network=$(printf "%016d" $(echo "ibase=16;obase=2;$(echo $network | tr -d :)" | bc))
    
    # Find the binary representation of the gateway IP
    local binary_gateway=$(echo ${binary_network:0:$((${#binary_network} - num_zeros))} | sed 's/.\{4\}/&:/g')
    
    # Convert binary to hexadecimal
    local gateway=$(echo $binary_gateway | sed 's/:$//g' | xxd -r -p | xxd -b | cut -d' ' -f2- | sed 's/ //g' | awk '{ printf "%04X:", strtonum("0b" $0) }' | sed 's/:$//g')
    
    echo "Gateway IP Address: ${gateway}"
}

# Main script
read -p "Enter the subnet CIDR (e.g., 2601:9202:1:20c::/64): " subnet_cidr

# Check if the input is valid
if [[ ! $subnet_cidr =~ ^[0-9a-fA-F:]+/[0-9]+$ ]]; then
    echo "Invalid subnet CIDR format. Please enter a valid CIDR (e.g., 2601:9202:1:20c::/64)."
    exit 1
fi

# Calculate and display the gateway IP address
calculate_gateway_ip "$subnet_cidr"
