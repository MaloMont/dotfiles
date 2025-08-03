import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Controls
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root

    property string artist: ""
    property string track: "No track playing"
    property string thumbnail
    property string status: "Playing"
    property string durationDisplay: "00:00"
    property string progressDisplay: "00:00"
    property int duration: 0
    property int progress: 0
    property string command: "play-pause"
    property string player
    property var players: ["No players available"]
    property string iconName: "media-playback-start-symbolic"
    property bool show: false

    implicitHeight: 300
    implicitWidth: 600
    WlrLayershell.layer: WlrLayer.Overlay
    color: "transparent"

    Region {
        id: maskRegion
    }
    mask: show ? null : maskRegion

    Item {
        anchors.fill: parent
        visible: opacity > 0
        opacity: show ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#aa000000"
            border.color: "#99ffffff"
            border.width: 3
        }

        // make sure to add the following to your hyprland config
        // bind = $mainMod SHIFT, A, global, quickshell:player
        GlobalShortcut {
          name: "player"
          description: "Play/pause media"

          onPressed: {
            console.log("musicManagerActivated.")
            root.show = !root.show
          }
        }

        // process for fetching metadata (handles both default player and selected player)
        Process {
            id: playerProc
            command: ["/bin/sh", "-c",
            player ?
            `playerctl --player ${player} metadata artist &&
            playerctl --player ${player} metadata title &&
            playerctl --player ${player} metadata mpris:artUrl &&
            playerctl status &&
            playerctl --player ${player} metadata mpris:length &&
            playerctl --player ${player} position &&
            playerctl --list-all`
            :
            "playerctl metadata artist &&
            playerctl metadata title &&
            playerctl metadata mpris:artUrl &&
            playerctl status &&
            playerctl metadata mpris:length &&
            playerctl position &&
            playerctl --list-all"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    const split = this.text.split("\n")
                    split.pop()
                    function secondsToMinutes(time) {
                        const minutes = Math.floor(time / 60);
                        const seconds = Math.round(time % 60);
                        return `${minutes < 10 ? "0" + minutes : minutes}:${seconds < 10 ? "0" + seconds : seconds}`;
                        }

                    artist = split[0]
                    track = split[1]
                    thumbnail = split[2]
                    status = split[3]
                    root.iconName = (status === "Playing")
        ? "media-playback-pause-symbolic"
        : "media-playback-start-symbolic"
                    duration = split[4] / 1000000
                    progress = split[5]
                    players = split.slice(6)
                    durationDisplay = secondsToMinutes(duration)
                    progressDisplay = secondsToMinutes(progress)
                }
            }
        }


        Timer {
            interval: 100
            running: true
            repeat: true
            onTriggered: {
                playerProc.running = true
                if (status === "Playing")
                    root.iconName = "media-playback-pause-symbolic"
                else
                    root.iconName = "media-playback-start-symbolic"

            }
        }

        // process for controlling the player
        Process {
            id: controlProc
            property string cmd: "play-pause"

            function run() {
                this.command = ["/bin/sh", "-c", !player.length ? `playerctl ${cmd}` : `playerctl --player ${player} ${cmd}`]
                this.running = true
            }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 60
            spacing: 40
            Image {
                source: thumbnail
                height: 190
                width: 190
            }
            Column {
                spacing: 20
                Column {
                    spacing: 5
                    Text {
                        font.bold: true
                        width: 300
                        wrapMode: Text.Wrap
                        font.pixelSize: 20
                        color: "white"
                        text: track || "No track playing"
                    }

                    Text {
                        font.pixelSize: 16
                        color: "#cccccc"
                        text: artist
                    }

                    Text {
                        font.pixelSize: 16
                        color: "white"
                        text: `${progressDisplay || "00:00"} / ${durationDisplay || "00:00"}`
                    }
                }
                Column {
                    ComboBox {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 250
                        height: 30
                        model: players
                        background: Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "#dd000000"
                        }
                        currentIndex: -1

                        onActivated: {
                            player = currentText
                        }
                    }
                    spacing: 10
                    Rectangle {
                        width: 250
                        height: 10
                        radius: 10
                        color: "#70cccccc"
                        Rectangle {
                            width: parent.width * (progress / duration)
                            height: parent.height
                            radius: parent.radius
                            color: "white"
                        }
                        MouseArea {
                            width: parent.width
                            height: parent.height
                            focus: true
                            anchors.fill: parent
                            onClicked: {
                                const jump = (mouse.x / parent.width) * duration
                                controlProc.cmd = `position ${jump}`
                                controlProc.run()
                            }
                        }
                    }
                    Row {
                        spacing: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        Button {
                            height: 40
                            width: 40
                            background: Rectangle {
                                color: "transparent"
                            }
                                IconImage {
                                    id: backIcon
                                    anchors.centerIn: parent
                                    anchors.fill: parent
                                    visible: false
                                    source: Quickshell.iconPath("media-skip-backward")
                                }

                                ColorOverlay {
                                    anchors.fill: parent
                                    source: backIcon
                                    color: "white"
                                }
                                onClicked: () => {
                                    controlProc.cmd = "previous"
                                    controlProc.run()
                                }
                            }
                        Button {
                            height: 40
                            width: 40
                            id: pauseplay
                            background: Rectangle {
                                color: "transparent"
                            }
                            IconImage {
                                id: pauseIcon
                                anchors.centerIn: parent
                                anchors.fill: parent
                                visible: true
                                source: Quickshell.iconPath(root.iconName)
                            }

                            ColorOverlay {
                                anchors.fill: parent
                                source: pauseIcon
                                color: "white"
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: false
                                }
                            }

                            onClicked: {
                                controlProc.cmd = "play-pause"
                                controlProc.run()
                            }
                        }
                        Button {
                            height: 40
                            width: 40
                            background: Rectangle {
                                color: "transparent"
                            }
                            IconImage {
                                id: skipIcon
                                anchors.centerIn: parent
                                anchors.fill: parent
                                visible: false
                                source: Quickshell.iconPath("media-skip-forward")
                            }

                            ColorOverlay {
                                anchors.fill: parent
                                source: skipIcon
                                color: "white"
                            }

                            onClicked: () => {
                                controlProc.cmd = "next"
                                controlProc.run()
                            }
                        }
                    }
                }
            }
        }
    }
}