// with this line our type becomes a Singleton
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// your singletons should always have Singleton as the type
Singleton {
    id: root

    readonly property string time: {
        Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss")
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}