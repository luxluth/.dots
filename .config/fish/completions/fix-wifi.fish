complete -c fix-wifi -f -a "(nmcli -t -f NAME,TYPE connection | string match '*:802-11-wireless' | string replace ':802-11-wireless' '')" -d "Wi-Fi Connection"
