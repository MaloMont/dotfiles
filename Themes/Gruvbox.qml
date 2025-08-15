pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: gruvbox

    property var base: "#32302F"
    property var dark_base: "#1D2021"
    property var surface: "#665C54"
    property var overlay: "#928374"

    property var intensity1: "#928374"
    property var intensity2: "#FABD2F"
    property var intensity3: "#FE8019"
    property var valid: "#8EC07C"
    property var error: "#FB4934"
    property var text: "#EBDBB2"
    property var textFocused: intensity2
    property var fontFamily: "ComicShannsMono Nerd Font"

    property var dockBorderColor: intensity1
}
