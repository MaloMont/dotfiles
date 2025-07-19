import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

import "root:/"


Item
{
    property bool focused
    property bool occupied
    property int iWorkspace
    property int size: Theme.widgetSize

    MarginWrapperManager {
        margin: 0
    }

    Rectangle
    {
        implicitWidth: (focused) ? 30 : size
        implicitHeight: size

        radius: 8

        color: (focused)
            ? Theme.intensity3
            : (occupied) ? Theme.intensity2 : Theme.intensity1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Hyprland.dispatch(`workspace ${index + 1}`)
        }

        Behavior on implicitWidth {
            NumberAnimation { duration: 80 }
        }
    }
}
