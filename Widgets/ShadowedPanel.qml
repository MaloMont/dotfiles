import Quickshell
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: root

    required property var src
    required property bool enable

    color: "transparent"

    MultiEffect {
        source: root.src
        anchors.fill: root.src
        shadowBlur: 0.7
        shadowEnabled: root.enable
        shadowColor: "black"
        shadowVerticalOffset: 0
        shadowHorizontalOffset: 0
    }

}