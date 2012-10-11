#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xset b off &
#/usr/bin/xinput set-prop 11 "Device Enabled" 0 &
#exec ck-launch-session dbus-launch --sh-syntax gnome-session
#exec ck-launch-session dbus-launch --sh-syntax --exit-with-session openbox-session
/usr/bin/SpiderOak &
exec ck-launch-session dbus-launch --sh-syntax --exit-with-session awesome
# exec startkde
# exec startxfce4
# ...or the Window Manager of your choice
