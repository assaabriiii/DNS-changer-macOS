#!/bin/bash

HISTORY_FILE="$HOME/dns_history.txt"

list_dns() {
    echo "Current DNS servers:"
    networksetup -getdnsservers Wi-Fi
}

save_dns_to_history() {
    current_dns=$(networksetup -getdnsservers Wi-Fi)
    if [ "$current_dns" != "There aren't any DNS Servers set on Wi-Fi." ]; then
        echo "$current_dns" >> "$HISTORY_FILE"
        echo "DNS servers saved to history."
    fi
}

change_dns() {
    echo "Enter the DNS servers you want to use (separated by space):"
    read -r dns_servers
    sudo networksetup -setdnsservers Wi-Fi $dns_servers
    save_dns_to_history
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
    save_dns_to_history
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
        save_dns_to_history
        echo "DNS server has been deleted. Updated DNS servers: $updated_dns"
    fi
}

add_dns_from_history() {
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "No history file found."
        return
    fi

    history_dns=($(cat "$HISTORY_FILE" | tr ' ' '\n' | sort | uniq))
    
    if [ ${#history_dns[@]} -eq 0 ]; then
        echo "No DNS servers in history."
        return
    fi

    echo "DNS servers in history:"
    for i in "${!history_dns[@]}"; do
        echo "$((i+1))-${history_dns[i]}"
    done
    
    echo "Enter the number of the DNS server you want to add:"
    read -r add_index
    
    if [ "$add_index" -le 0 ] || [ "$add_index" -gt "${#history_dns[@]}" ]; then
        echo "Invalid selection."
        return
    fi
    
    new_dns=${history_dns[$((add_index-1))]}
    current_dns=$(networksetup -getdnsservers Wi-Fi)
    updated_dns="$current_dns $new_dns"
    
    sudo networksetup -setdnsservers Wi-Fi $updated_dns
    echo "DNS server $new_dns has been added. Updated DNS servers: $updated_dns"
}

# Main menu
while true; do
    echo "Choose an option:"
    echo "1. List current DNS servers"
    echo "2. Change DNS servers (OVERWRITES CURRENT ONES"
    echo "3. Add a DNS server"
    echo "4. Delete a DNS server"
    echo "5. Add a DNS server from history"
    echo "6. Exit"
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
            add_dns_from_history
            ;;
        6)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo
done
