import QtQuick
import Quickshell
import Quickshell.Widgets
import "../"

Item {
    id: root

    MarginWrapperManager {
        margin: 0
    }

    Rectangle {
        id: button

        color: "transparent"
        radius: 100

        MarginWrapperManager {
            margin: 0
        }

        Text {
            id: icon

            text: ""

            color: buttonMouseArea.containsMouse ? Theme.textFocused : Theme.text

            font.pointSize: Theme.fontSize
            font.family: Theme.fontFamily

            MouseArea {
                id: buttonMouseArea
                anchors.fill: icon

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    dashboard.visible = !dashboard.visible
                }
            }
        }
    }

    Dashboard {
        id: dashboard

        anchors.top: root.bottom
        anchors.right: root.right

        visible: false
    }

    Connections {
        target: AppStates
        function onModeChanged() {
            if(AppStates.mode == AppStates.pointDockMod)
                dashboard.visible = false
        }
    }
}
