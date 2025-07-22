// ClockWidget.qml
import QtQuick
import Quickshell
import Quickshell.Widgets


Item {
    id: timeWidget

    MarginWrapperManager {
        margin: 0
    }

    property var calendar: Calendar {
        
    }

    Text {
        text: Time.time

        color: Theme.text
        font.pointSize: Theme.fontSize

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                timeWidget.calendar.visible = !timeWidget.calendar.visible
            }
        }
    }
}

