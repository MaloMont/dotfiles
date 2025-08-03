import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/"

Item {
    id: root

	readonly property var process: Process {
		command: ["sh", "-c", "wlogout"]
	}

	function exec() {
		process.startDetached();
	}

    Text {
        id: icon
        text: "⏻"
        font.pointSize: Theme.fontSize
        font.family: Theme.fontFamily
        anchors.centerIn: parent
        color: mouseArea.containsMouse ? Theme.intensity3 : Theme.text
    }

    MouseArea {
        id: mouseArea
        anchors.fill: icon
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: exec()
    }
}