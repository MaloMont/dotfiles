pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: theme

    property var base: "#1E1E2E"
    property var dark_base: "#11111B"
    property var surface: "#585b70"
    property var overlay: "#9399b2"

    property var intensity1: "#74c7ec"
    property var intensity2: "#fab387"
    property var intensity3: "#f38ba8"
    property var valid: "#a6e3a1"
    property var text: "#cdd6f4"

    property real radius: 13

    property int widgetSize: 12
    property int fontSize: 11
}