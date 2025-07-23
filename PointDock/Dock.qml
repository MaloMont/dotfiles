import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../Widgets" as Widgets
import "root:/"

PanelWindow {

    anchors {
        top: true
        bottom: true
        right: true
        left: true
    }

    color: "transparent"

    mask: Region { item: window }

    Rectangle {
        id: window
        color: Theme.base

        border.color: Theme.intensity1
        border.width: 2

        x: parent.x + parent.width - 85
        y: parent.y + parent.height - 85
        implicitWidth: 75
        implicitHeight: 75

        radius: 10

        MouseArea {
            anchors.fill: parent
            drag.target: window
            drag.axis: Drag.XAndYAxis

            onClicked: {
                panel.visible = !panel.visible
            }
        }

        ColumnLayout {

            anchors.centerIn: parent

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignHCenter
                text: Time.dayTime
                color: Theme.text
                font.pointSize: Theme.fontSize
            }

            Widgets.Battery {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}