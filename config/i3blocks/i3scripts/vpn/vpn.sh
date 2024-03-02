#!/bin/bash

disconnect() {
    nmcli con down id "$active" && notify-send -u normal -t 3000 -i network-offline "Network Manager" "Disconnected from $active" || notify-send -u critical -t 3000 -i error "Network Manager" "Error disconnecting from $active!"
}

connect() {
    nmcli con up id "$chosen" && notify-send -u normal -t 3000 -i network-vpn "Network Manager" "Now connected to $chosen" || notify-send -u critical -t 3000 -i error "Network Manager" "Error connecting to $chosen!"
}


# Get the active VPN connection if there's one
active="$(nmcli -g name,type con show --active | grep vpn | sed -e 's#:vpn$##')"

# Get the list of VPNs
mapfile -t list < <(nmcli -g name,type con | grep vpn | sed -e 's#:vpn$##')
# A VPN is active
if [ -n "$active" ]; then
    special="-a 0 -selected-row 1"
    # Variable passed to rofi
    options="$active"
    for i in "${!list[@]}"; do
        [ "${list[i]}" == "$active" ] && unset "list[i]" || options+="\n${list[i]}"
    done
else
    # Variable passed to rofi
    options=""
    for i in "${!list[@]}"; do
        options+="${list[i]}\n"
    done
    options=${options::-2}
fi

# Run rofi with customized GUI
chosen=$(echo -e "$options" | rofi -dmenu -i -p "VPN Connection" $special -lines 10 -padding 20 -location 1 -width 30 -hide-scrollbar -color-window "$bg_color, $bg_color, $bg_color" -color-normal "$text_color, $bg_color, $text_color, $selected_bg, $selected_fg" -color-active "$text_color, $green, $text_color, $selected_bg, $selected_fg" -color-urgent "$text_color, $red, $text_color, $selected_bg, $selected_fg" -bw 2 -separator-style "solid" -font "Noto Sans 12" -css "prompt { background-color: $prompt_bg; }")

if [ -n "$chosen" ]; then
    if [ "$chosen" == "$active" ]; then
        # Disconnect the active VPN
        disconnect
    else
        take_action=false
        # Check if the chosen option is in the list, to avoid taking action
        # on the user pressing Escape for example
        for i in "${!list[@]}"; do
            [ "${list[i]}" == "$chosen" ] && { take_action=true; break; }
        done
        if $take_action; then
            # A VPN is active
            if [ -n "$active" ]; then
                # Disconnect the active VPN
                disconnect
                wait
                sleep 1
                # Connect to the chosen one
                connect
            # No VPN is active
            else
                # Connect to the chosen one
                connect
            fi
        fi
    fi
fi
