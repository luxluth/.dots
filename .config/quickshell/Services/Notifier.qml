import QtQuick
import Quickshell.Services.Notifications

Item {
    id: root

    property alias tracked: nsTrackedModel
    property alias groups: groupsModel
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
        for (let i = groupsModel.count - 1; i >= 0; i--) {
            const group = groupsModel.get(i);
            const notifs = group.notifications;

            for (let j = notifs.count - 1; j >= 0; j--) {
                notifs.get(j).notification.dismiss();
            }
        }
    }

    function dismissGroup(appName) {
        for (let i = 0; i < groupsModel.count; i++) {
            const group = groupsModel.get(i);

            if (group.appName === appName) {
                const notifs = group.notifications;

                for (let j = notifs.count - 1; j >= 0; j--) {
                    notifs.get(j).notification.dismiss();
                }

                break;
            }
        }
    }

    ListModel {
        id: nsTrackedModel
    }

    ListModel {
        id: groupsModel
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

            // Flat model for compatibility
            nsTrackedModel.append({
                notification: n
            });

            // Grouped model
            let groupIndex = -1;

            for (let i = 0; i < groupsModel.count; i++) {
                if (groupsModel.get(i).appName === n.appName) {
                    groupIndex = i;
                    break;
                }
            }

            let group;

            if (groupIndex === -1) {
                groupsModel.insert(0, {
                    appName: n.appName,
                    appIcon: n.appIcon || n.appName || "application-x-executable",
                    notifications: []
                });

                group = groupsModel.get(0);
                // Need to use a real ListModel for nested notifications to get animations
                // But ListModel.get(0).notifications = [] doesn't work well for nesting in JS.
                // However, QML handles the conversion if we treat it as a model.
            } else {
                group = groupsModel.get(groupIndex);

                if (groupIndex > 0) {
                    groupsModel.move(groupIndex, 0, 1);
                    group = groupsModel.get(0);
                }
            }

            group.notifications.append({
                notification: n
            });

            n.closed.connect(() => {
                delete root.notificationTimes[n.id];

                // Cleanup flat model
                for (let i = 0; i < nsTrackedModel.count; i++) {
                    if (nsTrackedModel.get(i).notification === n) {
                        nsTrackedModel.remove(i);
                        break;
                    }
                }

                // Cleanup grouped model
                for (let i = 0; i < groupsModel.count; i++) {
                    const g = groupsModel.get(i);

                    if (g.appName === n.appName) {
                        const notifs = g.notifications;
                        for (let j = 0; j < notifs.count; j++) {
                            if (notifs.get(j).notification === n) {
                                notifs.remove(j);
                                break;
                            }
                        }

                        if (notifs.count === 0) {
                            groupsModel.remove(i);
                        }
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
