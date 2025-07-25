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
        Region { item: wifiContainer }
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
                fast.show = !fast.show
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
        id: fast

        property bool show: false
        property int space: 15
        property int fixedItemHeight: 32
        property int centerX: parent.width / 2
        property int centerY: parent.height / 2

        FirstLvlElem {
            id: wifiContainer

            function getRelPos() {
                if(!fast.show)
                    return RelativePos.center

                if(window.y < fast.centerY)
                    return RelativePos.bottom
                else
                    return RelativePos.top
            }

            show: fast.show
            boundX: window.x
            boundY: window.y
            boundW: window.width
            boundH: window.height
            boundSpace: fast.space
            relPos: getRelPos()

            Widgets.Wifi {
                id: wifi
                anchors.centerIn: parent
            }

            implicitHeight: fast.fixedItemHeight
            implicitWidth: wifi.width + (fast.fixedItemHeight - wifi.height)

            onXChanged: {
                console.log("WINDOW:", window.x, window.y)
                console.log("wifi :", x, y, opacity)
            }
        }


        FirstLvlElem {
            id: volumeContainer

            function getRelPos() {
                if(!fast.show)
                    return RelativePos.center

                if(window.y < fast.centerY) {
                    if(window.x < fast.centerX)
                        return RelativePos.bottomRight
                    else
                        return RelativePos.bottomLeft
                }else {
                    if(window.x < fast.centerX)
                        return RelativePos.topRight
                    else
                        return RelativePos.topLeft
                }
            }

            show: fast.show
            boundX: window.x
            boundY: window.y
            boundW: window.width
            boundH: window.height
            boundSpace: fast.space
            relPos: getRelPos()

            Widgets.Volume {
                id: volume
                anchors.centerIn: parent
            }

            implicitHeight: fast.fixedItemHeight
            implicitWidth: volume.width + (fast.fixedItemHeight - volume.height)

            onXChanged: {
                console.log("volume :", x, y, opacity)
            }
        }


        FirstLvlElem {
            id: workspacesContainer

            function getRelPos() {
                if(!fast.show)
                    return RelativePos.center

                if(window.x < fast.centerX)
                    return RelativePos.right
                else
                    return RelativePos.left
            }

            show: fast.show
            boundX: window.x
            boundY: window.y
            boundW: window.width
            boundH: window.height
            boundSpace: fast.space
            relPos: getRelPos()

            Widgets.Workspaces {
                id: workspaces
                anchors.centerIn: parent
            }

            implicitHeight: fast.fixedItemHeight
            implicitWidth: workspaces.width + (fast.fixedItemHeight - workspaces.height)

            onXChanged: {
                console.log("workspaces :", x, y, opacity)
            }
        }
    }
}
