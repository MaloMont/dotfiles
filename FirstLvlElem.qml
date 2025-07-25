import QtQuick


Rectangle {

    required property bool show
    required property int boundX
    required property int boundY
    required property int boundW
    required property int boundH
    required property int boundSpace
    required property var relPos

    function xPos() {
        if(relPos == RelativePos.topLeft || relPos == RelativePos.left || relPos == RelativePos.bottomLeft)
            return boundX - width - boundSpace
        if(relPos == RelativePos.top || relPos == RelativePos.center || relPos == RelativePos.bottom)
            return boundX + boundW / 2 - width / 2
        if(relPos == RelativePos.topRight || relPos == RelativePos.right || relPos == RelativePos.bottomRight)
            return boundX + boundW + boundSpace
    }

    function yPos() {
        if(relPos == RelativePos.topLeft || relPos == RelativePos.top || relPos == RelativePos.topRight)
            return boundY - height - boundSpace
        if(relPos == RelativePos.left || relPos == RelativePos.center || relPos == RelativePos.right)
            return boundY + boundH / 2 - height / 2
        if(relPos == RelativePos.bottomLeft || relPos == RelativePos.bottom || relPos == RelativePos.bottomRight)
            return boundY + boundH + boundSpace
    }

    radius: 100

    opacity: show ? 1 : 0

    x: xPos()
    y: yPos()

    color: Theme.base

    border.color: Theme.dockBorderColor
    border.width: 2

    Behavior on x {
        NumberAnimation { duration: 80 }
    }

    Behavior on y {
        NumberAnimation { duration: 80 }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 80
            easing.type: Easing.InOutQuad
        }
    }
}
