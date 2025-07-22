import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: widgets

    color: Theme.base

    bottomLeftRadius: Theme.radius

    MarginWrapperManager {
        margin: 0
        leftMargin: 15
        rightMargin: 15
    }

    implicitHeight: 30

    RowLayout {

        spacing: 0

        Wifi {
            Layout.alignment: Qt.AlignVCenter
        }

        Music {}

        Volume {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignVCenter
        }

        Battery {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignVCenter
        }

        Clock {
            Layout.alignment: Qt.AlignVCenter
        }

        PowerMgr {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
