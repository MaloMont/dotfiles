import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "root:/"

Rectangle {
    property int hMargin: 10

    color: Theme.base
    bottomLeftRadius: Theme.radius
    bottomRightRadius: Theme.radius

    MarginWrapperManager {
        margin: 10
    }

    RowLayout {
        spacing: hMargin

        // list of networks
        ColumnLayout {

            Layout.alignment: Qt.AlignVCenter

            spacing: 5

            // error / connect message
            Text {
                visible: Network.connecting || Network.errorHappened
                Layout.margins: 10
                text: (Network.connecting) ? "connecting" + curLoadingIcon : "An error occured.\nUse nmcli instead." 
                color: (Network.connecting) ? Theme.intensity2 : Theme.error

                font.pointSize: Theme.fontSize
                font.family: Theme.fontFamily

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: Network.errorHappened = false
                }
            }

            // no network message
            Text {
                visible: Network.networks.length == 0
                Layout.margins: 10
                text: "no network detected."
                color: Theme.error
                font.pointSize: Theme.fontSize
                font.family: Theme.fontFamily
            }

            // detected network list
            Repeater {
                model: ScriptModel {
                    values: [...Network.networks].sort((a, b) => {
                        if (a.active !== b.active)
                            return b.active - a.active;
                        return b.strength - a.strength;
                    }).slice(0, 8)
                }

                Rectangle {
                    id: networkItem

                    required property Network.AccessPoint modelData

                    color: Theme.surface
                    border.width: (networkItem.modelData.active || (Network.connecting && Network.ssidConnecting == networkItem.modelData.ssid)) ? 1 : 0
                    border.color: (networkItem.modelData.active) ? Theme.valid : Theme.intensity2

                    implicitHeight: 40
                    implicitWidth: 300
                    radius: Theme.radius

                    MouseArea {
                        anchors.fill: networkItem
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (networkItem.modelData.active) {
                                Network.disconnectFromNetwork();
                            } else {
                                Network.connectToNetwork(networkItem.modelData.ssid, "");
                            }
                        }
                    }

                    RowLayout {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        spacing: 10

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 10

                            text: networkItem.modelData.strengthIcon

                            font.pointSize: Theme.fontSize
                            font.family: Theme.fontFamily

                            color: (networkItem.modelData.active) ? Theme.valid : Theme.text
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter

                            text: (networkItem.modelData.isSecure) ? "󰌾" : ""
                            color: (networkItem.modelData.isSecure) ? Theme.valid : Theme.error

                            font.pointSize: Theme.fontSize
                            font.family: Theme.fontFamily
                        }

                        Text {
                            text: networkItem.modelData.ssid
                            elide: Text.ElideRight
                            color: (Network.connecting && Network.ssidConnecting == networkItem.modelData.ssid) ? Theme.intensity2
                                : (networkItem.modelData.active) ? Theme.valid : Theme.text
                        }
                    }
                }
            }
        }

//        // sent/received 
//        ColumnLayout {
//
//            Layout.alignment: Qt.AlignVCenter
//
//            spacing: 10
//
//            Histogram {
//                Layout.alignment: Qt.AlignHCenter
//                historyData: Network.sentHistory
//                title: `${Network.sent} Mb `
//                maxValue: 100
//            }
//
//            Histogram {
//                Layout.alignment: Qt.AlignHCenter
//                historyData: Network.receivedHistory
//                title: `${Network.received} Mb `
//                maxValue: 500
//            }
//        }
    }

    readonly property list<string> loadingIcons: [".  ", ".. ", "..."]
    property int iLoadingIcon: 0
    property string curLoadingIcon: loadingIcons[iLoadingIcon]

    Timer {
        interval: 800

        running: true
        repeat: true

        onTriggered: iLoadingIcon = (iLoadingIcon + 1) % loadingIcons.length
    }
}