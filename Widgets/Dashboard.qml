import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "Workspaces"
import "../"

ShadowedPanel {

    src: row
    enable: visible

    implicitWidth: panelBackground.width + smouthCornerLeft.width +  + smouthCornerRight.width
    implicitHeight: panelBackground.height + 100

    RowLayout {
        id: row
        spacing: 0

        Smouth {
            id: smouthCornerLeft
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
            bottomRightRadius: Theme.radius
            color: Theme.base

            ColumnLayout {
                spacing: 20

                implicitWidth: 450

                RowLayout {
                    spacing: 20

                    Layout.minimumWidth: parent.width
                    Layout.maximumWidth: parent.width
                    Layout.minimumHeight: 40

                    uniformCellSizes: true

                    Battery {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    }

                    WifiButton {
                        id: wifiBtn
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    }

                    ShutdownButton {
                        id: shutdownBtn
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    }
                }

                Shutdown {
                    visible: shutdownBtn.interfaceVisible
                    Layout.alignment: Qt.AlignHCenter
                    Layout.minimumWidth: parent.width
                    Layout.maximumWidth: parent.width
                    Layout.minimumHeight: 40
                }

                Wifi {
                    visible: wifiBtn.interfaceVisible
                    id: wifiInterface
                    Layout.row: 2
                    Layout.column: 10
                    Layout.columnSpan: 3
                    Layout.alignment: Qt.AlignHCenter
                    hMargin: 20
                }

                Volume {
                    Layout.row: 5
                    Layout.column: 10
                    Layout.columnSpan: 3
                    Layout.alignment: Qt.AlignHCenter
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
                    requiredWidth: parent.width - 20
                }
            }
        }

        Smouth {
            id: smouthCornerRight
            Layout.alignment: Qt.AlignTop
            topLeftVisible: true
        }
    }
}

/// TODO: brightness
/// (cpu usage)
/// network data upload/download
