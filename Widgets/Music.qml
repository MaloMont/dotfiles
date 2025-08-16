import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/"


Item {
    id: root

    property bool inDashboard: false
    property int requiredWidth: 0
    property int requiredHeight: 0
    property int coverSize: 0
    property var player: Mpris.players.values[0]
    property bool playing: player?.isPlaying || false
    property real trackCurTime: player?.position
    property real trackTotalTime: player?.length
    property bool musicExists: ( (Mpris.players.values?.length || 0) > 0 )
    property var trackName: player?.trackTitle || "Unknown Title"
    property var trackArtist: player?.trackArtist || "Unknown Artist"
    property var artUrl: player?.trackArtUrl || "noMusic.png"

    // position is not updated automatically by quickshell (unless some brutal change occur)
    // we do that manually every second
    Timer {
        running: player.playbackState == MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: {
            root.player.positionChanged()
        }
    }

    function toMinutes(seconds) {
        var min = Math.round(Math.round(seconds) / 60)
        var sec = Math.round(seconds) % 60

        return (sec < 10) ? `${min}:0${sec}` : `${min}:${sec}`
    }

    MarginWrapperManager {
        margin: 0
    }

    RowLayout {
        spacing: 10

        // cover image
        ClippingRectangle {
            visible: root.inDashboard
            property int size: root.coverSize

            implicitWidth: size
            implicitHeight: size
            radius: 5

            // TODO: round corners
            Image {
                anchors.fill: parent
                id: mediaArt

                visible: inDashboard

                source: Qt.resolvedUrl(artUrl)
                fillMode: Image.PreserveAspectCrop
                cache: false
                antialiasing: true
                asynchronous: true

                sourceSize.width: root.coverSize
                sourceSize.height: root.coverSize
            }
        }

        ColumnLayout {
            spacing: 10

            // title + artist info text
            Text {
                id: trackText
                Layout.alignment: Qt.AlignHCenter

                text: (musicExists) ? `${trackName} (${trackArtist})` : "󰎊"
                color: (inDashboard)
                        ? (playing) ? Theme.intensity2 : Theme.text
                        : (playing) ? (textMouseArea.containsMouse) ? Theme.intensity2 : Theme.text : Theme.text

                font.pointSize: Theme.fontSize
                font.family: Theme.fontFamily

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                Layout.maximumWidth: root.requiredWidth != 0 ? root.requiredWidth - root.coverSize : 400
                elide: Text.ElideRight

                MouseArea {
                    id: textMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        trackText.clicked.connect(player?.togglePlaying())
                    }
                }
            }

            // progress bar
            Rectangle {
                visible: inDashboard && root.musicExists

                implicitWidth: root.requiredWidth - root.coverSize
                implicitHeight: 10

                color: Theme.surface
                radius: 100

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    implicitWidth: parent.implicitWidth * (root.trackCurTime / root.trackTotalTime)
                    color: Theme.intensity2
                    radius: 100
                }
            }
            
            // control buttons
            RowLayout {
                visible: inDashboard && root.musicExists
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Text {
                    visible: inDashboard && root.musicExists

                    color: Theme.surface

                    text: `${toMinutes(root.trackCurTime)}`
                }

                Text {
                    id: previousButton
                    text: "󰙣"
                    color: Theme.intensity2

                    font.pointSize: Theme.fontSize * 2
                    font.family: Theme.fontFamily

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Layout.maximumWidth: root.requiredWidth != 0 ? root.requiredWidth : 400
                    elide: Text.ElideRight

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            playPauseButton.clicked.connect(player?.previous())
                        }
                    }
                }

                Text {
                    id: playPauseButton
                    text: playing ? "" : ""
                    color: Theme.intensity2

                    font.pointSize: Theme.fontSize * 2
                    font.family: Theme.fontFamily

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Layout.maximumWidth: root.requiredWidth != 0 ? root.requiredWidth : 400
                    elide: Text.ElideRight

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            playPauseButton.clicked.connect(player?.togglePlaying())
                        }
                    }
                }

                Text {
                    id: nextButton
                    text: "󰙡"
                    color: Theme.intensity2

                    font.pointSize: Theme.fontSize * 2
                    font.family: Theme.fontFamily

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Layout.maximumWidth: root.requiredWidth != 0 ? root.requiredWidth : 400
                    elide: Text.ElideRight

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            playPauseButton.clicked.connect(player?.next())
                        }
                    }
                }

                Text {
                    visible: inDashboard && root.musicExists

                    color: Theme.surface

                    text: `  ${toMinutes(root.trackTotalTime)}`
                }
            }
        }
    }
}