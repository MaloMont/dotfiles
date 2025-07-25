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
        id: background

        color: "transparent"
        radius: 100

        MarginWrapperManager {
            margin: 0
        }

        Text {
            id: icon

            text: AppStates.mode == AppStates.barMod
                ? "→ dock"
                : "→ bar"

            color: button.containsMouse ? Theme.textFocused : Theme.text

            font.pointSize: Theme.fontSize

            MouseArea {
                id: button
                anchors.fill: icon

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    AppStates.mode = !AppStates.mode
                }
            }
        }
    }
}
