pragma Singleton

import Quickshell
import QtQuick
import "Themes" as Themes

Singleton {

    property var theme: Themes.Gruvbox

    property var base: theme.base
    property var dark_base: theme.dark_base
    property var surface: theme.surface
    property var overlay: theme.overlay

    property var intensity1: theme.intensity1
    property var intensity2: theme.intensity2
    property var intensity3: theme.intensity3
    property var valid: theme.valid
    property var error: theme.error
    property var text: theme.text
    property var textFocused: theme.textFocused
    property var active: theme.intensity2
    property var hoovered: theme.intensity3

    property var dockBorderColor: theme.dockBorderColor

    property real radius: 13
    property int widgetSize: 12

    property var fontFamily: "ComicShannsMono Nerd Font"
    property int smallFontSize: 8
    property int fontSize: 11
    property int midFontSize: 16
    property int bigFontSize: 20
}
