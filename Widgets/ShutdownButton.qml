import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/"

Item {
    id: root

    property bool interfaceVisible: false

    MarginWrapperManager {}

    Text {
        color: mouseArea.containsMouse ? Theme.hoovered
             : (interfaceVisible) ? Theme.active : Theme.text

        text: (interfaceVisible) ? "" : ""
        font.pointSize: Theme.fontSize
        font.family: Theme.fontFamily

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: interfaceVisible = !interfaceVisible
        }
    }
}