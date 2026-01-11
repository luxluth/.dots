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
}
