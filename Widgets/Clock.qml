import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:/"


Item {
    id: timeWidget

    MarginWrapperManager {
        margin: 0
    }

    property var calendar: Calendar {
        
    }

    Text {
        text: Time.time

        color: (timeMouseArea.containsMouse) ? Theme.intensity2 : Theme.text
        font.pointSize: Theme.fontSize
        font.family: Theme.fontFamily

        MouseArea {
            id: timeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                timeWidget.calendar.visible = !timeWidget.calendar.visible
            }
        }
    }
}

