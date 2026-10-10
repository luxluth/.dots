function lastin --description 'Show last user login and tty'
    lastlog2 -u $USER | awk 'NR==2 { print "Last login (" $4 " " $5 " " $6 "" $9 ") - " $2 }'
end
