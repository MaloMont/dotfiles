pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: cappuccin

    property var base: "#1E1E2E"
    property var dark_base: "#11111B"
    property var surface: "#585b70"
    property var overlay: "#9399b2"

    property var intensity1: "#74c7ec"
    property var intensity2: "#fab387"
    property var intensity3: "#f38ba8"
    property var valid: "#a6e3a1"
    property var error: "#f38ba8"
    property var text: "#cdd6f4"
    property var textFocused: intensity2 //"#f5e0dc"
    property var fontFamily: "ComicShannsMono Nerd Font"

    property var dockBorderColor: intensity1
}
