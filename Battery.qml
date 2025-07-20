import QtQuick
import Quickshell.Io
import Quickshell.Widgets

Item {

    MarginWrapperManager {
        margin: 0
        leftMargin: 10
        rightMargin: 10
    }

    Text {
        id: widget

        property string battery
        property bool hasBattery: false

        visible: hasBattery

        anchors.fill: parent

        font.family: "ComicShannsMono Nerd Font"
        font.pointSize: Theme.fontSize
        text: battery
        color: Theme.text

        Process {
            id: batteryCheck
            command: ["sh", "-c", "test -d /sys/class/power_supply/BAT*"]
            running: true
            onExited: function(exitCode) { widget.hasBattery = exitCode === 0 }
        }

        Process {
            id: batteryProc
            // Modify command to get both capacity and status in one call
            command: ["sh", "-c", "echo $(cat /sys/class/power_supply/BAT*/capacity),$(cat /sys/class/power_supply/BAT*/status)"]
            running: widget.hasBattery

            stdout: SplitParser {
            onRead: function(data) {
                const [capacityStr, status] = data.trim().split(',')
                const capacity = parseInt(capacityStr)
                let batteryIcon = "󰂂"
                if (capacity <= 20) batteryIcon = "󰁺"
                else if (capacity <= 40) batteryIcon = "󰁽"
                else if (capacity <= 60) batteryIcon = "󰁿"
                else if (capacity <= 80) batteryIcon = "󰂁"
                else batteryIcon = "󰂂"
                
                const symbol = status === "Charging" ? "󰂄" : batteryIcon
                widget.battery = `${symbol} ${capacity}%`
                widget.color = status === "Charging" ? Theme.valid : Theme.intensity2
            }
            }
        }

        Timer {
            interval: 1000
            running: widget.hasBattery
            repeat: true
            onTriggered: batteryProc.running = true
        }
    }
}
