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

>>>>>>>>>>>>>

#!/bin/bash

calculate_gateway_ip() {
    local subnet_cidr=$1
    local network=$(echo "$subnet_cidr" | cut -d/ -f1)
    local last_group_hex=$(echo "$network" | awk -F: '{print $NF}')
    local last_group_dec=$((16#${last_group_hex}))
    local next_group_dec=$((last_group_dec + 1))
    local next_group_hex=$(printf "%x" "$next_group_dec")
    local gateway=$(echo "$network" | sed "s/$last_group_hex$/$next_group_hex/")
    echo "Gateway IP Address: ${gateway}"
}

read -p "Enter the subnet CIDR (e.g., ): " subnet_cidr
calculate_gateway_ip "$subnet_cidr"
>>>>>>>>>>>>>>>>>>>>

#!/bin/bash

# Get the CIDR notation from user input
read -p "Enter the CIDR notation (e.g.,): " cidr

# Extract the network address and prefix length from the CIDR notation
network=$(echo $cidr | cut -d '/' -f 1)
prefix_length=$(echo $cidr | cut -d '/' -f 2)

# Calculate the network address with /64 prefix length
network_with_64_prefix=$(printf "%s/%s" ${network%:*} $prefix_length)

# Use the ip command to find the gateway for the network
gateway=$(ip -6 route show | grep $network_with_64_prefix | awk '{print $3}')

echo "Gateway for $cidr is $gateway"


>>>>>>>>>>>>>>>.

#!/bin/bash

# Function to calculate the IPv6 gateway
calculate_ipv6_gateway() {
  cidr="$1"

  # Check if valid IPv6 CIDR using cut and grep
  if ! echo "$cidr" | grep -E '^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}(\/[0-9]{1,3})?$' >/dev/null 2>&1; then
    echo "Invalid IPv6 CIDR notation provided."
    return 1
  fi

  # Extract IP address and prefix length
  ip_address="${cidr%%/*}"
  prefix_length="${cidr##*/}"

  # Convert prefix length to bit length for calculation
  bits=$((128 - prefix_length))

  # Set the last bit of the network address to 1 for the gateway (using shift)
  gateway=$((0x$(echo "$ip_address" | tr ':' ' ' | awk '{ sum += $1; printf("%04x", sum) }') << (bits - 1)))

  # Combine modified address part with original prefix
  gateway_address="${ip_address%%:*}:$((gateway >> 16))"
  for ((i=1; i<7; ++i)); do
    gateway_address="$gateway_address:${((gateway >> (16 * i) & 0xFFFF))}"
  done
  gateway_address="$gateway_address:${gateway & 0xFFFF}"

  echo "$gateway_address/$prefix_length"
}

# Get CIDR input from user
read -p "Enter IPv6 CIDR notation (e.g.): " cidr

# Calculate and display gateway
gateway=$(calculate_ipv6_gateway "$cidr")
if [[ $? -eq 0 ]]; then
  echo "IPv6 Gateway: $gateway"
fi

>>>>>>>>>>>>>>>>>>>>.

#!/bin/bash

# Function to calculate the IPv6 gateway
calculate_ipv6_gateway() {
  cidr="$1"

  # Validate CIDR format and extract address/prefix using grep
  if ! echo "$cidr" | grep -E '^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}(\/[0-9]{1,3})?$' >/dev/null 2>&1; then
    echo "Invalid IPv6 CIDR notation provided."
    return 1
  fi
  ip_address="${cidr%%/*}"
  prefix_length="${cidr##*/}"

  # Calculate bit position and set last bit for gateway (using arithmetic expansion)
  gateway=$(( 0x$(echo "$ip_address" | tr ':' ' ' | awk '{ sum += $1; printf("%04x", sum) }') | (1<< (128-$prefix_length-1)) ))

  # Build gateway address with modified last octet and original prefix
  gateway_address="${ip_address%%:*}:$((gateway >> 16))"
  for ((i=1; i<7; ++i)); do
    gateway_address="$gateway_address:${((gateway >> (16 * i) & 0xFFFF))}"
  done
  gateway_address="$gateway_address:${gateway & 0xFFFF}"

  echo "$gateway_address/$prefix_length"
}

# Get CIDR input from user
read -p "Enter IPv6 CIDR notation (e.g., ): " cidr

# Calculate and display gateway
gateway=$(calculate_ipv6_gateway "$cidr")
if [[ $? -eq 0 ]]; then
  echo "IPv6 Gateway: $gateway"
fi
