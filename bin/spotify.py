#!/usr/bin/python

import dbus
import os
import sys


try:
    bus = dbus.SessionBus()
    spotifyd = bus.get_object("org.mpris.MediaPlayer2.spotifyd", "/org/mpris/MediaPlayer2")


    if os.environ.get('BLOCK_BUTTON'):
        control_iface = dbus.Interface(spotifyd, 'org.mpris.MediaPlayer2.Player')
        if (os.environ['BLOCK_BUTTON'] == '1'):
            control_iface.Previous()
        elif (os.environ['BLOCK_BUTTON'] == '2'):
            control_iface.PlayPause()
        elif (os.environ['BLOCK_BUTTON'] == '3'):
            control_iface.Next()

    spotifyd_iface = dbus.Interface(spotifyd, 'org.freedesktop.DBus.Properties')
    props = spotifyd_iface.Get('org.mpris.MediaPlayer2.Player', 'Metadata')

    if (sys.version_info > (3, 0)):
        print(str(props['xesam:artist'][0]) + " - " + str(props['xesam:title'].partition('-')[0]))
    else:
        print(props['xesam:artist'][0] + " - " + props['xesam:title']).partition('-')[0].encode('utf-8')
    exit
except dbus.exceptions.DBusException:
    exit
