import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import "root:/"


Item {
	id: volume

    property bool inDashboard: false
    property var icon: " "
    property var requiredWidth: 0
    property var requiredHeight: 0

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
			var value = (Pipewire.defaultAudioSink?.audio.volume ?? 0)

            if(value == 0)
                icon = "󰸈"
            else if(value < .20)
                icon = ""
            else if(value < .40)
                icon = ""
            else
                icon = " "
		}
	}

    implicitWidth: requiredWidth != 0 ? requiredWidth : 75 // fixed value = max value (changing icon !=> changing size)
    implicitHeight: rowLayout.height

    RowLayout {
        id: rowLayout

        Text {
            id: volumeIcon
            text: icon
            font.family: "ComicShannsMono Nerd Font"
            color: (inDashboard) ? Theme.intensity2 : Theme.text
            font.pointSize: Theme.fontSize
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            // Stretches to fill all left-over space

            Layout.alignment: Qt.AlignVCenter

            implicitWidth: volume.implicitWidth - volumeIcon.width
            implicitHeight: requiredHeight != 0 ? requiredHeight : Theme.widgetSize

            radius: 10
            color: Theme.surface

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                radius: parent.radius
                color: (inDashboard) ? Theme.intensity2 : Theme.text
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: false

                onWheel: (wheel) => {
                    Pipewire.defaultAudioSink.audio.volume += wheel.angleDelta.y * 0.001
                    if(Pipewire.defaultAudioSink.audio.volume > 1.)
                        Pipewire.defaultAudioSink.audio.volume = 1.
                }
            }
        }
    }
}