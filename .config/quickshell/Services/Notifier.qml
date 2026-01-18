import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property alias tracked: nsTrackedModel
    property var notificationTimes: ({})
    signal notificationReceived(Notification notification)

    function timeAgo(date) {
        if (!date)
            return "";
        const now = new Date();
        const diff = (now.getTime() - date.getTime()) / 1000;

        if (diff < 60)
            return "Just now";
        if (diff < 3600)
            return Math.floor(diff / 60) + "m ago";
        if (diff < 86400)
            return Math.floor(diff / 3600) + "h ago";
        return Math.floor(diff / 86400) + "d ago";
    }

    function dismissAll() {
        for (let i = nsTrackedModel.count - 1; i >= 0; i--) {
            const item = nsTrackedModel.get(i);
            if (item && item.notification) {
                item.notification.dismiss();
            }
        }
    }

    ListModel {
        id: nsTrackedModel
    }

    NotificationServer {
        id: nServer
        actionsSupported: true
        bodyMarkupSupported: true

        Component.onCompleted: {
            const initial = trackedNotifications.values;
            for (let i = 0; i < initial.length; i++) {
                handleNewNotification(initial[i]);
            }
        }

        function handleNewNotification(n) {
            root.notificationTimes[n.id] = new Date();
            nsTrackedModel.append({
                notification: n
            });

            n.closed.connect(() => {
                delete root.notificationTimes[n.id];
                for (let i = 0; i < nsTrackedModel.count; i++) {
                    if (nsTrackedModel.get(i).notification === n) {
                        nsTrackedModel.remove(i);
                        break;
                    }
                }
            });
        }

        onNotification: n => {
            n.tracked = true;
            handleNewNotification(n);
            root.notificationReceived(n);
        }
    }
}
