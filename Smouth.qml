import QtQuick

Rectangle {
    implicitWidth: 30
    implicitHeight: 30

    color: "transparent"

    property bool topRightVisible: false
    property bool topLeftVisible: false

    Image {
        id: imgTopRight
        visible: parent.topRightVisible
        anchors.fill: parent
        source: "smouthBorderTopRight.png"
    }

    Image {
        id: imgTopLeft
        visible: parent.topLeftVisible
        anchors.fill: parent
        source: "smouthBorderTopLeft.png"
    }
}