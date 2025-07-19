// ClockWidget.qml
import QtQuick
import Quickshell
import Quickshell.Widgets


Text {
    text: Time.time

    color: Theme.text
    font.pointSize: Theme.fontSize
}
