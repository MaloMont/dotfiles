pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: relativePos

    property var top: 0
    property var topLeft: 1
    property var left: 2
    property var bottomLeft: 3
    property var bottom: 4
    property var bottomRight: 5
    property var right: 6
    property var topRight: 7
    property var center: 8
}
