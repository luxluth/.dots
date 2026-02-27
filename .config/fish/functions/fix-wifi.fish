function fix-wifi --description "Disables PMF on a given Wi-Fi connection to fix WPA2 handshakes"
    if test -z "$argv[1]"
        echo "Error: Please provide a Wi-Fi connection name."
        echo "Usage: fix-wifi 'WiFi_Name'"
        return 1
    end

    set SSID $argv[1]
    echo "Disabling PMF (802.11w) for: $SSID..."
    nmcli connection modify "$SSID" 802-11-wireless-security.pmf 1

    echo "Attempting to reconnect..."
    nmcli connection up "$SSID" --ask
end
