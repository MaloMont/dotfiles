import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: powerMgr

    property bool panelVisible: false

    MarginWrapperManager {
        margin: 0
        leftMargin: 10
    }

    Rectangle {
        id: barButton
        radius: 100
        implicitWidth: 20
        implicitHeight: 20
        color: buttonArea.containsMouse ? Theme.dark_base : "transparent"

        Text {
            anchors.centerIn: parent
            text: "s"
            color: buttonArea.containsMouse ? Theme.textFocused : Theme.text
        }

        MouseArea {
            id: buttonArea
            anchors.fill: parent
            onClicked: powerMgr.panelVisible = !powerMgr.panelVisible
        }
    }

    // TODO: chesscom daily problem
    // TODO: insta, whatsapp, discord? dur

    PanelWindow {
        visible: powerMgr.panelVisible

        anchors.right: powerMgr.right
        anchors.top: powerMgr.bottom

        implicitWidth: 500
        implicitHeight: 450

        color: "transparent"

        Rectangle {
            anchors.fill: parent
            id: panelBackground

            color: Theme.base

            radius: Theme.radius
        }
    }
}