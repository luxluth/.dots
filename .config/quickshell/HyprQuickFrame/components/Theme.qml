/*
 * Copyright (c) 2026 Ronin-CK
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // Self-contained Colors loader to avoid out-of-config directory imports
    property QtObject colors: QtObject {
        property bool isDarkThemed: true

        property FileView fileView: FileView {
            path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
            watchChanges: true
            onFileChanged: reload()

            JsonAdapter {
                id: jsonAdapter
                readonly property ThemeNode dark: ThemeNode {}
                readonly property ThemeNode light: ThemeNode {}
            }
        }

        component ThemeNode: JsonObject {
            property Md3 md3: Md3 {}
        }

        component Md3: JsonObject {
            property string surface: "#14140c"
            property string on_surface: "#e5e3d6"
            property string outline: "#929182"
            property string outline_variant: "#48473b"
            property string primary_container: "#474a01"
            property string primary: "#c8cc78"
            property string tertiary: "#a3d0bf"
            property string error: "#ffb4ab"
            property string surface_container: "#202018"
            property string surface_container_lowest: "#0e0f08"
        }

        property var md3: isDarkThemed ? jsonAdapter.dark.md3 : jsonAdapter.light.md3

        property color fg: md3.on_surface
        property color bg: md3.surface
        property color border: md3.outline
        property color muted: md3.outline_variant
        property color contrast: isDarkThemed ? md3.surface_container : md3.surface_container_lowest
        property color accentContainer: md3.primary_container
        property color accentOutline: md3.primary
        property color green: md3.tertiary
        property color red: md3.error
        property color transparentBg: Qt.rgba(bg.r, bg.g, bg.b, 0.85)
        property color transparentFg: Qt.rgba(fg.r, fg.g, fg.b, 0.5)
        property string fontFamily: "Fantasque Sans Mono"
    }

    property QtObject colorSchemeProcess: Process {
        running: true
        command: ["dconf", "read", "/org/gnome/desktop/interface/color-scheme"]
        stdout: SplitParser {
            onRead: data => {
                let d = data.trim().replace(/'/g, "");
                root.colors.isDarkThemed = (d === "prefer-dark");
            }
        }
    }

    property var source: ({
    })
    readonly property color accent: _get("accent", colors.accentContainer)
    readonly property color accentText: _get("accentText", colors.fg)
    readonly property real dimOpacity: _get("dimOpacity", 0.6)
    readonly property int borderRadius: _get("borderRadius", 10)
    readonly property int outlineThickness: _get("outlineThickness", 2)
    readonly property real bottomMargin: _get("bottomMargin", 60)
    readonly property bool animations: _get("animations", true)
    readonly property string annotationTool: _get("annotationTool", "satty")
    readonly property color barBackground: _get("barBackground", colors.transparentBg)
    readonly property color barBorder: _get("barBorder", colors.border)
    readonly property color barText: _get("barText", colors.transparentFg)
    readonly property color barShadow: _get("barShadow", "#80000000")
    readonly property color toggleBackground: _get("toggleBackground", accent)
    readonly property color toggleShadow: _get("toggleShadow", "#80000000")
    readonly property color toggleEdit: _get("toggleEdit", colors.green)
    readonly property color toggleTemp: _get("toggleTemp", colors.accentOutline)
    readonly property color shareConnected: _get("shareConnected", colors.green)
    readonly property color sharePending: _get("sharePending", colors.transparentFg)
    readonly property color shareErrorIcon: _get("shareErrorIcon", "white")
    readonly property color shareErrorBackground: _get("shareErrorBackground", colors.red)
    readonly property string fontFamily: _get("fontFamily", colors.fontFamily)
    readonly property string postSaveHook: source.hooksPostSaveHook || ""

    function _get(key, fallback) {
        let val = source[key];
        val = (val !== undefined && val !== null) ? val : fallback;
        // Support CSS-style rgba(r, g, b, a)
        if (typeof val === "string") {
            // Check for 8-digit hex (RRGGBBAA) - commonly used in web/CSS
            if (val.match(/^#[0-9a-fA-F]{8}$/)) {
                let r = parseInt(val.substring(1, 3), 16) / 255;
                let g = parseInt(val.substring(3, 5), 16) / 255;
                let b = parseInt(val.substring(5, 7), 16) / 255;
                let a = parseInt(val.substring(7, 9), 16) / 255;
                return Qt.rgba(r, g, b, a);
            }
            const rgbaMatch = val.match(/rgba\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)/);
            if (rgbaMatch)
                return Qt.rgba(parseInt(rgbaMatch[1]) / 255, parseInt(rgbaMatch[2]) / 255, parseInt(rgbaMatch[3]) / 255, parseFloat(rgbaMatch[4]));

        }
        return val;
    }

}
