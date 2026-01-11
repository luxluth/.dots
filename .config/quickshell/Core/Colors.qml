import QtQuick

Item {
    id: root

    required property var context

    property string theme: context.theme
    property bool isDarkThemed: context.theme === "prefer-dark"
    property string fontFamily: "Fantasque Sans Mono"
    property color fg: isDarkThemed ? "#fff" : "#181818"
    property color bg: isDarkThemed ? "#181818" : "#f7f7f7"
    property color muted: isDarkThemed ? "#444" : "#ccc"
    property color border: isDarkThemed ? "#595959" : "#444"
    property color contrast: isDarkThemed ? "#222" : "#fff"

    property color green: "#26a65b"
    property color red: "#f53c3c"

    property color pearleBlue: isDarkThemed ? "#6269E5" : "#A0BFFF"
    property color pearleBlueStroke: isDarkThemed ? "#7A80E7" : "#7E83E7"

    Behavior on bg {
        ColorAnimation {
            duration: 100
        }
    }

    Behavior on fg {
        ColorAnimation {
            duration: 100
        }
    }

    Behavior on muted {
        ColorAnimation {
            duration: 100
        }
    }

    Behavior on border {
        ColorAnimation {
            duration: 100
        }
    }

    Behavior on contrast {
        ColorAnimation {
            duration: 100
        }
    }

    Behavior on green {
        ColorAnimation {
            duration: 100
        }
    }

    Behavior on red {
        ColorAnimation {
            duration: 100
        }
    }

    Behavior on pearleBlue {
        ColorAnimation {
            duration: 100
        }
    }

    Behavior on pearleBlueStroke {
        ColorAnimation {
            duration: 100
        }
    }
}
