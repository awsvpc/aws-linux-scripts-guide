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


>>>>>>>>>>>>>>>>>>>>>>.

#!/bin/bash

# Function to calculate the gateway IP address
calculate_gateway_ip() {
    local subnet_cidr=$1
    local subnet=${subnet_cidr%/*}
    local cidr=${subnet_cidr#*/}
    
    local network=$(ipcalc -n $subnet_cidr | cut -d= -f2)
    local last_hex=$(echo $network | awk -F: '{print $NF}')
    
    # Convert the last hexadecimal octet to decimal, add 1, and convert it back to hexadecimal
    local gateway_hex=$(printf "%x\n" $((16#$last_hex + 1)))
    
    # Pad with zeros if necessary
    gateway_hex=$(printf "%04s" $gateway_hex)
    
    # Reconstruct the IPv6 address with the updated last octet
    local gateway=$(echo $network | sed "s/:$last_hex$/:$gateway_hex/")
    
    echo "Gateway IP Address: ${gateway}"
}

# Main script
read -p "Enter the subnet CIDR (e.g.,): " subnet_cidr

# Calculate and display the gateway IP address
calculate_gateway_ip "$subnet_cidr"


>>>>>>>>>>>>>>>>>>>.

#!/bin/bash

# Function to calculate the gateway IP address
calculate_gateway_ip() {
    local subnet_cidr=$1
    local subnet=${subnet_cidr%/*}
    local cidr=${subnet_cidr#*/}
    
    # Extract the network portion of the subnet
    local network=$(echo $subnet | cut -d/ -f1)

    # Extract the last 4 groups of the network address
    local last_4_groups=$(echo $network | awk -F: '{print $(NF-3),$(NF-2),$(NF-1),$NF}')
    
    # Convert the last group to decimal, add 1, and convert it back to hexadecimal
    local last_group_dec=$((16#${last_4_groups##*:} + 1))
    local last_group_hex=$(printf "%x" $last_group_dec)
    
    # Reconstruct the IPv6 address with the updated last group
    local gateway=$(echo $network | sed "s/$last_4_groups$/$last_group_hex/")
    
    echo "Gateway IP Address: ${gateway}"
}

# Main script
read -p "Enter the subnet CIDR (e.g.,): " subnet_cidr

# Calculate and display the gateway IP address
calculate_gateway_ip "$subnet_cidr"

>>>>>>>>>>>>>>>>>>>>>>

#!/bin/bash

calculate_gateway_ip() {
    local subnet_cidr=$1
    local network=$(echo "$subnet_cidr" | cut -d/ -f1)
    local last_group_dec=$((16#$(echo "$network" | awk -F: '{print $(NF)}') + 1))
    local gateway=$(echo "$network" | sed "s/::[^:]*$/::$(printf "%x" $last_group_dec)/")
    echo "Gateway IP Address: ${gateway}"
}

read -p "Enter the subnet CIDR (e.g.,): " subnet_cidr
calculate_gateway_ip "$subnet_cidr"


#!/bin/bash

calculate_gateway_ip() {
    local subnet_cidr=$1
    local subnet=${subnet_cidr%/*}
    local last_group_dec=$((16#$(echo $subnet | awk -F: '{print $(NF-1)}') + 1))
    local gateway=$(echo $subnet | sed "s/::.*:/::$(printf "%x" $last_group_dec):/")
    echo "Gateway IP Address: ${gateway}"
}

read -p "Enter the subnet CIDR (e.g.,): " subnet_cidr
calculate_gateway_ip "$subnet_cidr"

