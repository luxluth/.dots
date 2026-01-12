import QtQuick
import "../Assets"
import "../Core"

QtObject {
    id: root
    required property Colors colors

    property var actions: [
        {
            active: false,
            icon: Icons.plane,
            action: (item, proc) => {}
        },
        {
            active: false,
            icon: Icons.bellOff,
            action: (item, proc) => {}
        },
        {
            active: false,
            icon: Icons.logOut,
            action: (item, proc) => {}
        },
        {
            active: false,
            icon: Icons.rotateCCW,
            action: (item, proc) => {}
        },
        {
            active: false,
            icon: Icons.lock,
            action: (item, proc) => {}
        },
        {
            active: false,
            icon: Icons.power,
            color: root.colors.red,
            action: (item, proc) => {}
        },
    ]
}
