#!/bin/bash

list_dns() {
    echo "Current DNS servers:"
    networksetup -getdnsservers Wi-Fi
}

change_dns() {
    echo "Enter the DNS servers you want to use (separated by space):"
    read -r dns_servers
    sudo networksetup -setdnsservers Wi-Fi $dns_servers
    echo "DNS servers have been updated to: $dns_servers"
}

add_dns() {
    echo "Enter the DNS server you want to add:"
    read -r new_dns
    current_dns=$(networksetup -getdnsservers Wi-Fi)
    if [ "$current_dns" == "There aren't any DNS Servers set on Wi-Fi." ]; then
        current_dns=""
    fi
    updated_dns="$current_dns $new_dns"
    sudo networksetup -setdnsservers Wi-Fi $updated_dns
    echo "DNS server $new_dns has been added. Updated DNS servers: $updated_dns"
}

delete_dns() {
    current_dns=($(networksetup -getdnsservers Wi-Fi))
    
    if [ ${#current_dns[@]} -eq 0 ]; then
        echo "No DNS servers are set."
        return
    fi
    
    echo "Current DNS servers:"
    for i in "${!current_dns[@]}"; do
        echo "$((i+1))-${current_dns[i]}"
    done
    
    echo "Enter the number of the DNS server you want to delete:"
    read -r del_index
    
    if [ "$del_index" -le 0 ] || [ "$del_index" -gt "${#current_dns[@]}" ]; then
        echo "Invalid selection."
        return
    fi
    
    unset current_dns[$((del_index-1))]
    updated_dns="${current_dns[@]}"
    
    if [ -z "$updated_dns" ]; then
        sudo networksetup -setdnsservers Wi-Fi "Empty"
        echo "DNS server has been deleted. No DNS servers set."
    else
        sudo networksetup -setdnsservers Wi-Fi $updated_dns
        echo "DNS server has been deleted. Updated DNS servers: $updated_dns"
    fi
}

while true; do
    echo "Choose an option:"
    echo "1. List current DNS servers"
    echo "2. Change DNS servers (overwrites current ones)"
    echo "3. Add a DNS server"
    echo "4. Delete a DNS server"
    echo "5. Exit"
    read -r choice

    case $choice in
        1)
            list_dns
            ;;
        2)
            change_dns
            ;;
        3)
            add_dns
            ;;
        4)
            delete_dns
            ;;
        5)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo
done
