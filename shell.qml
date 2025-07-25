import Quickshell
import QtQuick

Scope {
    property var bar: Bar {
        visible: AppStates.mode == AppStates.barMod
    }

    property var dock: Dock {
        visible: AppStates.mode == AppStates.pointDockMod
    }
}
