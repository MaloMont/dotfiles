import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:/"


Item {
    id: timeWidget

    MarginWrapperManager {
        margin: 0
    }

    Calendar {
        id: calendar
        visible: false
    }

    Text {
        text: Time.time

        color: (timeMouseArea.containsMouse) ? Theme.hoovered
             : (calendar.visible) ? Theme.active : Theme.text

        font.pointSize: Theme.fontSize
        font.family: Theme.fontFamily

        MouseArea {
            id: timeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                calendar.visible = !calendar.visible
            }
        }
    }
}

