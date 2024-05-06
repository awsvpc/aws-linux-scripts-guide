#!/bin/bash

file="/etc/file.txt"

# List of strings to check and append
strings="string1
string2
string3"

# Loop through each string
while IFS= read -r string; do
    # Check if string not in file
    if ! grep -qF "$string" "$file"; then
        echo "$string" >> "$file"
    else
        echo "String '$string' already exists in the file. Skipping..."
    fi
done <<< "$strings"
