#!/bin/bash

# Function to calculate the gateway IP address
calculate_gateway_ip() {
    local subnet_cidr=$1
    local subnet=${subnet_cidr%/*}
    local cidr=${subnet_cidr#*/}
    
    local network=$(ipcalc -n $subnet_cidr | cut -d= -f2)
    local gateway=$(echo $network | awk -F. '{print $1"."$2"."$3"."($4+1)}')
    
    echo "Gateway IP Address: ${gateway}"
}

# Main script
read -p "Enter the subnet CIDR (e.g., 10.10.10.192/27): " subnet_cidr

# Calculate and display the gateway IP address
calculate_gateway_ip "$subnet_cidr"

>>>>>>>>>>>>>>>>>>>>>>

#!/bin/bash

# Function to calculate the gateway IP address
calculate_gateway_ip() {
    local subnet_cidr=$1
    local subnet=${subnet_cidr%/*}
    local cidr=${subnet_cidr#*/}
    
    local gateway=""
    
    # Split the subnet into octets
    IFS='.' read -r -a octets <<< "$subnet"
    
    # Calculate the gateway IP address
    local last_octet=$(((${octets[3]} | (2 ** (32 - cidr)) - 1) & ~(2 ** (32 - cidr - 1))))
    gateway="${octets[0]}.${octets[1]}.${octets[2]}.$last_octet"
    
    echo "Gateway IP Address: ${gateway}"
}

# Main script
read -p "Enter the subnet CIDR (e.g.): " subnet_cidr

# Check if the input is valid
if [[ ! $subnet_cidr =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
    echo "Invalid subnet CIDR format. Please enter a valid CIDR (e.g)."
    exit 1
fi

# Calculate and display the gateway IP address
calculate_gateway_ip "$subnet_cidr"

