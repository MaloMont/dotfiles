import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "Widgets" as Widgets
import "Widgets/Workspaces" as Widgets

PanelWindow {

    property int margin: 10 // between content and borders

    anchors {
        top: true
        bottom: true
        right: true
        left: true
    }

    color: "transparent"

    mask: Region {
        Region { item: window }
        Region { item: volumeContainer }
        Region { item: modSwitchContainer }
        Region { item: workspacesContainer }
    }

    Rectangle {
        id: window

        z: 3

        color: Theme.base

        border.color: Theme.dockBorderColor
        border.width: 2

        implicitWidth: 75
        implicitHeight: 75

        x: parent.width - implicitWidth - 10
        y: parent.height - implicitHeight - 10

        radius: 10

        MouseArea {
            anchors.fill: parent
            drag.target: window
            drag.axis: Drag.XAndYAxis

            onClicked: {
                orbiting.show = !orbiting.show
            }
        }

        ColumnLayout {

            anchors.centerIn: parent

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignHCenter
                text: Time.dayTime
                color: Theme.text
                font.pointSize: Theme.fontSize
            }

            Widgets.Battery {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Item {
        id: orbiting

        property bool show: false
        property int space: 15
        property int fixedItemHeight: 32
        property int centerX: parent.width / 2
        property int centerY: parent.height / 2
    }

    FirstLvlElem {
        id: modSwitchContainer

        function getRelPos() {
            if(!orbiting.show)
                return RelativePos.center

            if(window.y < orbiting.centerY)
                return RelativePos.bottom
            else
                return RelativePos.top
        }

        show: orbiting.show
        boundX: window.x
        boundY: window.y
        boundW: window.width
        boundH: window.height
        boundSpace: orbiting.space
        relPos: getRelPos()

        Widgets.ModSwitch {
            id: modSwitch
            anchors.centerIn: parent
        }

        implicitHeight: orbiting.fixedItemHeight
        implicitWidth: modSwitch.width + 10 + (orbiting.fixedItemHeight - modSwitch.height)
    }


    FirstLvlElem {
        id: volumeContainer

        function getRelPos() {
            if(!orbiting.show)
                return RelativePos.center

            if(window.y < orbiting.centerY) {
                if(window.x < orbiting.centerX)
                    return RelativePos.bottomRight
                else
                    return RelativePos.bottomLeft
            }else {
                if(window.x < orbiting.centerX)
                    return RelativePos.topRight
                else
                    return RelativePos.topLeft
            }
        }

        show: orbiting.show
        boundX: window.x
        boundY: window.y
        boundW: window.width
        boundH: window.height
        boundSpace: orbiting.space
        relPos: getRelPos()

        implicitHeight: orbiting.fixedItemHeight
        implicitWidth: volume.width + 1.5*(orbiting.fixedItemHeight - volume.height)

        Widgets.Volume {
            id: volume
            anchors.centerIn: parent
        }
    }


    FirstLvlElem {
        id: workspacesContainer

        function getRelPos() {
            if(!orbiting.show)
                return RelativePos.center

            if(window.x < orbiting.centerX)
                return RelativePos.right
            else
                return RelativePos.left
        }

        show: orbiting.show
        boundX: window.x
        boundY: window.y
        boundW: window.width
        boundH: window.height
        boundSpace: orbiting.space
        relPos: getRelPos()

        Widgets.Workspaces {
            id: workspaces
            anchors.centerIn: parent
        }

        implicitHeight: orbiting.fixedItemHeight
        implicitWidth: workspaces.width + (orbiting.fixedItemHeight - workspaces.height)
    }
}
