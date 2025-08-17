import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "Workspaces"
import "../"

PanelWindow {

    implicitWidth: panelBackground.width + smouthCorner.width
    implicitHeight: panelBackground.height

    color: "transparent"

    RowLayout {
        spacing: 0

        Smouth {
            id: smouthCorner
            Layout.alignment: Qt.AlignTop
            topRightVisible: true
        }

        Rectangle {
            id: panelBackground

            MarginWrapperManager {
                topMargin: 20
                bottomMargin: 15
                rightMargin: 15
                leftMargin: 15
            }

            bottomLeftRadius: Theme.radius
            color: Theme.base

            GridLayout {
                rowSpacing: 20
                columnSpacing: 0
                uniformCellWidths: true

                implicitWidth: 300

                Battery {
                    Layout.row: 0
                    Layout.column: 10
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                }

                WifiButton {
                    id: wifiBtn
                    Layout.row: 0
                    Layout.column: 11
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                }

                Shutdown {
                    Layout.row: 0
                    Layout.column: 12
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                }

                Wifi {
                    visible: wifiBtn.interfaceVisible
                    id: wifiInterface
                    Layout.row: 2
                    Layout.column: 10
                    Layout.columnSpan: 3
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                }

                Volume {
                    Layout.row: 5
                    Layout.column: 10
                    Layout.columnSpan: 3
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    inDashboard: true
                    requiredHeight: 20
                    requiredWidth: parent.width
                }

                Music {
                    visible: musicExists
                    Layout.column: 10
                    Layout.row: 10
                    Layout.columnSpan: 3
                    inDashboard: true
                    coverSize: 130
                    requiredWidth: 380
                }
            }
        }
    }
}

/// TODO: brightness
/// (cpu usage)
/// network data upload/download
