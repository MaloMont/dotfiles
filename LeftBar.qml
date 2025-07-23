// Bar.qml
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "Widgets/Workspaces" as Worksp


Rectangle {
    id: widgets

    color: Theme.base

    bottomRightRadius: Theme.radius

    MarginWrapperManager {
        margin: 4 // bouh hardcode
        leftMargin: 15
        rightMargin: 15
    }

    Worksp.Workspaces {
        anchors.centerIn: parent
    }
}
