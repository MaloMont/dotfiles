import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "Widgets" as Widgets

Rectangle {
    id: rightBar

    color: Theme.base

    bottomLeftRadius: Theme.radius

    MarginWrapperManager {
        margin: 0
        leftMargin: 15
        rightMargin: 15
    }

    implicitHeight: 30

    RowLayout {
        id: widgetRow
        spacing: 20

//        Widgets.ModSwitch {
//            Layout.alignment: Qt.AlignVCenter
//        }

        Widgets.Music {
            id: leftWidget
            Layout.alignment: Qt.AlignVCenter
        }

        Widgets.WifiButton {
            id: wifiBtn
            Layout.alignment: Qt.AlignVCenter
        }

        Widgets.Volume {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignVCenter
        }

        Widgets.Battery {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignVCenter
        }

        Widgets.Clock {
            Layout.alignment: Qt.AlignVCenter
        }


        Widgets.DashboardButton {
            Layout.alignment: Qt.AlignVCenter
        }
    }

// TODO: brightness, bluetooth

    Widgets.ShadowedPanel {

        src: panelElements
        enable: visible

        anchors.top: true
        anchors.right: true

        visible: wifiBtn.interfaceVisible

        implicitWidth: panelElements.width
        implicitHeight: panelElements.height + 20

        RowLayout {
            id: panelElements
            spacing: 0

            Smouth {
                id: smouthCornerLeft
                Layout.alignment: Qt.AlignTop
                topRightVisible: true
            }

            Widgets.Wifi {
                id: wifiPanelContent
            }

            Smouth {
                id: smouthCornerRight
                Layout.alignment: Qt.AlignTop
                topLeftVisible: true
            }
        }
    }
}
