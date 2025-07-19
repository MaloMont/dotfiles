// Bar.qml
import Quickshell
import Quickshell.Widgets
import QtQuick
import "Workspaces" as Worksp

Scope {

    Variants {
        model: Quickshell.screens // for each screen

        PanelWindow {
            property var modelData
            screen: modelData

            color: "transparent"

            implicitHeight: 30

            anchors {
                top: true
                left: true
                right: true
            }

            LeftBar {
                anchors.left: parent.left
            }

            RightBar {
                anchors.right: parent.right
            }
        }
    }
}