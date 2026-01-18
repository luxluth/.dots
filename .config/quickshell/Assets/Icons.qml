pragma Singleton
import QtQuick

QtObject {
    readonly property string wifiHigh: Qt.resolvedUrl("./wifi-high.svg")
    readonly property string wifiLow: Qt.resolvedUrl("./wifi-low.svg")
    readonly property string wifiMid: Qt.resolvedUrl("./wifi-mid.svg")
    readonly property string wifiOff: Qt.resolvedUrl("./wifi-off.svg")
    readonly property string wifiZero: Qt.resolvedUrl("./wifi-zero.svg")
    readonly property string wifiSync: Qt.resolvedUrl("./wifi-sync.svg")

    readonly property string bluetoothActive: Qt.resolvedUrl("./bluetooth-active.svg")
    readonly property string bluetoothConnected: Qt.resolvedUrl("./bluetooth-connected.svg")
    readonly property string bluetoothOff: Qt.resolvedUrl("./bluetooth-off.svg")

    readonly property string zap: Qt.resolvedUrl("./zap.svg")
    readonly property string scale: Qt.resolvedUrl("./scale.svg")
    readonly property string sproot: Qt.resolvedUrl("./sprout.svg")

    readonly property string chevronRight: Qt.resolvedUrl("./chevron-right.svg")

    readonly property string ethernetPort: Qt.resolvedUrl("./ethernet-port.svg")

    readonly property string volumeMute: Qt.resolvedUrl("./volume-x.svg")
    readonly property string volumeZero: Qt.resolvedUrl("./volume-0.svg")
    readonly property string volumeLow: Qt.resolvedUrl("./volume-1.svg")
    readonly property string volumeHigh: Qt.resolvedUrl("./volume-2.svg")

    readonly property string sunLow: Qt.resolvedUrl("./sun-dim.svg")
    readonly property string sunMid: Qt.resolvedUrl("./sun-medium.svg")
    readonly property string sunHigh: Qt.resolvedUrl("./sun.svg")

    readonly property string bellOff: Qt.resolvedUrl("./bell-off.svg")
    readonly property string bell: Qt.resolvedUrl("./bell.svg")

    readonly property string plane: Qt.resolvedUrl("./plane.svg")
    readonly property string logOut: Qt.resolvedUrl("./log-out.svg")
    readonly property string rotateCCW: Qt.resolvedUrl("./rotate-ccw.svg")
    readonly property string lock: Qt.resolvedUrl("./lock.svg")
    readonly property string power: Qt.resolvedUrl("./power.svg")

    readonly property string coffee: Qt.resolvedUrl("./coffe.svg")

    readonly property string micOn: Qt.resolvedUrl("./mic-on.svg")
    readonly property string micOff: Qt.resolvedUrl("./mic-off.svg")

    readonly property string close: Qt.resolvedUrl("./x.svg")
    readonly property string clean: Qt.resolvedUrl("./brush-clean.svg")

    readonly property string forward: Qt.resolvedUrl("./fast-forward.svg")
    readonly property string pause: Qt.resolvedUrl("./pause.svg")
    readonly property string play: Qt.resolvedUrl("./play.svg")
}
