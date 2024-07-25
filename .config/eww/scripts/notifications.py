#!/usr/bin/env python3
import subprocess
import json

global tmp_notif
tmp_notif = "/tmp/dunst-history.json"


def get_single_notif(json_data, id):
    # need to get the notification with the id
    for i in range(len(json_data["data"][0])):
        if json_data["data"][0][i]["id"]["data"] == id:
            return json_data["data"][0][i]


def get_notifs(ids, json_data):
    # Get the notifications
    notifications = []
    for id in ids:
        notifications.append(get_single_notif(json_data, id))

    return notifications


single_notif = """
(button :class "notifbtn" :onclick "dunstctl history-rm {_id} && dunstctl history > /tmp/dunst-history.json"
    (box
      :class "notification"
      :orientation "h"
      :width 600
      :space-evenly false
      
      (image
        :class "notification-icon"
        :path "{icon_path}"
        :image-height 50
        :image-width 100
      )
      
      (box
        :orientation "v"
        :space-evenly false
        :valign "start"
        :width 500

        
        (label
          :xalign 0
          :wrap true
          :class "notification-appname"
          :markup "{appname}"
        )
        
        (label
          :xalign 0
          :wrap true
          :width 300
          :class "notification-summary"
          :markup "{message}"
        )

      )
    )
)
"""


def inline(string):
    return string.replace("\n", " ")


def notif():
    # Read the notification from the notification file
    json_data = subprocess.run(
        ["dunstctl", "history"], capture_output=True
    ).stdout.decode("utf-8")
    notif_data = json.loads(json_data)

    # Get the notification ids
    ids = []
    for i in range(len(notif_data["data"][0])):
        ids.append(notif_data["data"][0][i]["id"]["data"])

    # Print the notifications
    notifs = get_notifs(ids, notif_data)

    notif_string = """(box
  :orientation "v"
  :space-evenly false
  :spacing 20
  :halign "start"
  """
    insert_count = 0

    for notif in notifs:
        if notif["progress"]["data"] == -1:
            notif_string += single_notif.format(
                appname=notif["appname"]["data"],
                icon_path=notif["icon_path"]["data"],
                message=notif["message"]["data"],
                _id=notif["id"]["data"],
            )
            insert_count += 1
    if insert_count > 0:
        notif_string += ")"
    else:
        notif_string += '"Notifications are empty")'

    print("\n" + inline(notif_string), flush=True, end="")


if __name__ == "__main__":
    notif()
