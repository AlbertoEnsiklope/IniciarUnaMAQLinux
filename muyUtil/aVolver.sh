#!/bin/bash
  expect -c '
  spawn sudo apt install ./chrome-remote-desktop_current_amd64.deb
    expect {
        "Do you want to continue? \\\[Y/n\\\]" { send "Y\r"; exp_continue }
        eof
    }
    sleep 20
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    send "\r"
    sleep 1
    send "84\r"
    sleep 1
    send "8\r"
    expect eof
    '

    sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver

    echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session
