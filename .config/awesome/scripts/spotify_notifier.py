#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""
Title: Spotify Notification Demo
Author: Stuart Colville, http://muffinresearch.co.uk
License: BSD

"""

import os
import dbus
import gobject
import pynotify
import httplib2
import sys
from urllib import quote
from cgi import escape
from hashlib import md5
from dbus.mainloop.glib import DBusGMainLoop
from dbus.exceptions import DBusException

HTTP_CACHE_DIR = os.path.expanduser("~/.cache/spotify/http/")
IMAGE_CACHE_DIR = os.path.expanduser("~/.cache/spotify/art/")   #Will fail if director doesn't exist
MISSING = os.path.realpath(os.path.join(os.path.dirname(__file__), "missing.png"))

#bus = dbus.SessionBus()
#player = bus.get_object("org.freedesktop.Notifications", "/")
#iface = dbus.Interface(player, "org.freedesktop.Notifications")


class SpotifyNotifier(object):

    def __init__(self):
        """initialise."""
        bus_loop = DBusGMainLoop(set_as_default=True)
        self.bus = dbus.SessionBus(mainloop=bus_loop)
        loop = gobject.MainLoop()
        self.http = httplib2.Http(HTTP_CACHE_DIR)
        self.notify_id = None
        try:
            self.props_changed_listener()
        except DBusException, e:
            if not ("org.mpris.MediaPlayer2.spotify "
                    "was not provided") in e.get_dbus_message():
                raise
        self.session_bus_spotify = self.bus.get_object("org.freedesktop.DBus",
                                 "/org/freedesktop/DBus")
        self.session_bus_spotify.connect_to_signal("NameOwnerChanged",
                                        self.handle_name_owner_changed,
                                        arg0="org.mpris.MediaPlayer2.spotify")

        self.session_bus_notifications = self.bus.get_object("org.freedesktop.Notifications", "/")
        self.iface_notifications = dbus.Interface(self.session_bus_notifications, "org.freedesktop.Notifications")

        loop.run()

    def props_changed_listener(self):
        """Hook up callback to PropertiesChanged event."""
        self.spotify = self.bus.get_object("org.mpris.MediaPlayer2.spotify",
                                           "/org/mpris/MediaPlayer2")
        self.spotify.connect_to_signal("PropertiesChanged",
                                        self.handle_properties_changed)

    def handle_name_owner_changed(self, name, older_owner, new_owner):
        """Introspect the NameOwnerChanged signal to work out if spotify has started."""
        if name == "org.mpris.MediaPlayer2.spotify":
            if new_owner:
                # spotify has been launched - hook it up.
                self.props_changed_listener()
            else:
                self.spotify = None

    def handle_properties_changed(self, interface, changed_props, invalidated_props):
        """Handle track changes."""
        metadata = changed_props.get("Metadata", {})
        if metadata:
            if pynotify.init("Spotify Notifier Demo"):

                title = unicode(metadata.get("xesam:title").encode('utf8'))
                album = unicode(metadata.get("xesam:album").encode('utf8'))
                artist = unicode(metadata.get("xesam:artist")[0].encode('utf8'))
                image_url = unicode(metadata.get("mpris:artUrl"))
                print title, album, artist, image_url
                hash_ = md5()
                hash_.update("%s-%s" % (artist, album))
                hash_path = hash_.hexdigest()
                image_path = os.path.join(IMAGE_CACHE_DIR, hash_path)
                if not os.path.exists(image_path):
                    try:
                        response, image_contents = self.http.request(image_url)
                        if image_contents:
                            try:
                                fh = open(image_path, "w")
                                fh.write(image_contents)
                                fh.close()
                            except Exception, e:
                                print str(e)
                                print >> sys.stderr, "Create IMAGE_CACHE_DIR if it doesn't exist"
                    except:
                        image_path = MISSING

                if image_path != MISSING:
                    #Uncomment if you want to use notification-daemon
                    """alert = pynotify.Notification(title.replace("&","&amp;"),"by <b>%s</b> from <b>%s</b>" % (artist.replace("&","&amp;"), album.replace("&","&amp;")), image_path)
                    if self.notify_id:
                        alert.props.id = self.notify_id
                    alert.set_urgency (pynotify.URGENCY_CRITICAL)
                    alert.set_timeout(1)
                    alert.show()
                    alert.close()"""
                    body = title.replace("&","&amp;"),"by %s from %s" % (artist.replace("&","&amp;"), album.replace("&","&amp;"))
                    self.iface_notifications.Notify("Spotify-Notifier", 0, image_path, "Song changed", "%s - %s" % body , "", {}, 5000)


if __name__ == "__main__":
    SpotifyNotifier()
