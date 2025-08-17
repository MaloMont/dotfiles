import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/"

RowLayout {

    spacing: 10


    readonly property var rebootProc: Process {
        command: ["systemctl", "reboot"]
    }

    readonly property var shutdownProc: Process {
        command: ["systemctl", "poweroff"]
    }

    readonly property var suspendProc: Process {
        command: ["systemctl", "suspend"]
    }

    readonly property var logoutProc: Process {
        command: ["sh", "-c", "loginctl terminate-user $USER"]
    }

    readonly property var lockProc: Process {
        command: ["hyprlock"]
    }

    readonly property var hibernateProc: Process {
        command: ["systemctl", "hibernate"]
    }


    Button {
        id: shutdown

        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        visible: interfaceVisible
        iconStr: "⏻"

        onExec: function shutdownFunc() {
            shutdownProc.startDetached();
        }
    }

    Button {
        id: suspend

        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        visible: interfaceVisible
        iconStr: ""

        onExec: function suspendFunc() {
            suspendProc.startDetached()
        }
    }

    Button {
        id: logout

        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        visible: interfaceVisible
        iconStr: "󰍃"

        onExec: function logoutFunc() {
            logoutProc.startDetached();
        }
    }

    Button {
        id: lock

        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        visible: interfaceVisible
        iconStr: ""

        onExec: function lockFunc() {
            lockProc.startDetached();
        }
    }

    Button {
        id: reboot

        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        visible: interfaceVisible
        iconStr: ""

        onExec: function rebootFunc() {
            rebootProc.startDetached();
        }
    }
}
