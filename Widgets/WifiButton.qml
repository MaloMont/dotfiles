import Quickshell
import Quickshell.Widgets
import QtQuick
import "root:/"

Item {
    property bool interfaceVisible: false

    MarginWrapperManager {
        margin: 0
    }

    Text {
        text: Network.icon
        font.family: Theme.fontFamily
        font.pointSize: Theme.fontSize
        color: (btnArea.containsMouse) ? Theme.intensity2
             : (interfaceVisible) ? Theme.intensity3 : Theme.text

        MouseArea {
            id: btnArea
            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                interfaceVisible = !interfaceVisible
            }
        }
    }
}