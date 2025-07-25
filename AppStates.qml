pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: appStates

    readonly property bool pointDockMod: true
    readonly property bool barMod: false

    property bool mode: barMod
}