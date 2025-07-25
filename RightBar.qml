import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import "Widgets" as Widgets

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

        spacing: 15

        Widgets.Wifi {
            Layout.alignment: Qt.AlignVCenter
        }

        Widgets.Music {}

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

        Widgets.ModSwitch {
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
