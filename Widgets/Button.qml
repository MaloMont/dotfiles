import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/"


Text {

    required property string iconStr
    required property var onExec

    id: icon

    color: mouseArea.containsMouse ? Theme.hoovered : Theme.text
    text: iconStr
    font.pointSize: Theme.fontSize
    font.family: Theme.fontFamily

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: onExec()
    }
}
