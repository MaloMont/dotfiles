import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "root:/"

Rectangle {
    id: root

    required property list<real> historyData
    property string title: ""

    property real maxValue: 500

    property int lineWidth: 2

    Component.onCompleted: {
        console.log(maxValue)
    }

    color: Theme.dark_base
    implicitWidth: 100
    implicitHeight: 50
    topLeftRadius: Theme.radius
    topRightRadius: Theme.radius

    ColumnLayout {
        anchors.fill: parent

        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            text: root.title
            font.family: Theme.fontFamily
            font.pointSize: Theme.fontSize
            color: Theme.intensity2
        }

        Rectangle {

            color: "transparent"

            RowLayout {
                anchors.fill: parent

                spacing: 0

                Repeater {
                    model: root.historyData

                    Rectangle {
                        id: bar
                        required property real modelData

                        Layout.alignment: Qt.AlignBottom

                        implicitWidth: root.implicitWidth / historyData.length
                        implicitHeight: calculateHeight(modelData)
                        color: Theme.surface
            
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right

                            color: Theme.intensity2
                            implicitHeight: lineWidth
                        }
                    }
                }
            }

            function calculateHeight(value) {
                if(maxValue == 0 || value == 0)
                    return lineWidth

                return root.implicitHeight * (value / maxValue)
            }
        }
    }
}
