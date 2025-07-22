// Bar.qml
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
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

            RowLayout {
                spacing: 0
                anchors.left: parent.left

                LeftBar {
                    Layout.fillHeight: true
                }

                Smouth {
                    topLeftVisible: true
                }
            }

            RowLayout {
                spacing: 0
                anchors.right: parent.right

                Smouth {
                    topRightVisible: true
                }

                RightBar {
                    Layout.fillHeight: true
                }
            }
        }
    }
}