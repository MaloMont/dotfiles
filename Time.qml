// with this line our type becomes a Singleton
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// your singletons should always have Singleton as the type
Singleton {
    id: root

    property var date: new Date()

    readonly property string time: {
        Qt.formatDateTime(clock.date, "ddd MMM d  hh:mm:ss") // 󱋱
    }

    readonly property string dayTime: {
        Qt.formatDateTime(clock.date, "hh:mm:ss")
    }


    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: root.date = new Date()
    }
}