import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Item {

    property bool playing: Mpris.players.values[0]?.isPlaying || false
    property bool musicExists: ( (Mpris.players.values?.length || 0) > 0 )
    property var player: Mpris.players.values[0]?.identity
    property var trackName: Mpris.players.values[0]?.trackTitle || "Unknown Title"

    MarginWrapperManager {
        margin: 0
    }

    Text {
        id: track
        
        text: (musicExists) ? `${trackName}` : "no music"
        color: (musicExists)
            ? (playing) ? Theme.intensity2 : Theme.surface
            : Theme.text

        font.pointSize: Theme.fontSize

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter


        MouseArea {
            anchors.fill: parent
            onClicked: {
                track.clicked.connect(Mpris.players.values[0]?.togglePlaying())
            }
        }
    }
}