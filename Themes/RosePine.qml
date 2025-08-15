pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: rosePine

    property var base: "#191724"
    property var dark_base: "#000"
    property var surface: "#524f67"
    property var overlay: "#908caa"

    property var intensity1: "#c4a7e7"
    property var intensity2: "#f6c177"
    property var intensity3: "#eb6f92"
    property var valid: "#9ccfd8"
    property var error: "#f38ba8"
    property var text: "#e0def4"
    property var textFocused: intensity2 //"#f5e0dc"
    property var fontFamily: "ComicShannsMono Nerd Font"

    property var dockBorderColor: intensity1
}
