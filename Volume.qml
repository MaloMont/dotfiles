import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Item {
	id: volume

    property var icon: " "

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

    MarginWrapperManager {
        margin: 0
        leftMargin: 15
        rightMargin: 15
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 15
        }

        Text {
            text: icon
            font.family: "ComicShannsMono Nerd Font"
            color: Theme.intensity2
            font.pointSize: Theme.fontSize
            Layout.fillHeight: true
        }

        Rectangle {
            // Stretches to fill all left-over space

            Layout.alignment: Qt.AlignVCenter

            implicitWidth: 50
            implicitHeight: Theme.widgetSize

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
                color: Theme.intensity2
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: false

                onWheel: (wheel) => {
                    console.log("delta:", wheel.angleDelta.y)
                    Pipewire.defaultAudioSink.audio.volume += wheel.angleDelta.y * 0.001
                    if(Pipewire.defaultAudioSink.audio.volume > 1.)
                        Pipewire.defaultAudioSink.audio.volume = 1.
                }
            }
        }
    }
}