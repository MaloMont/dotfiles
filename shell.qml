// shell.qml
import Quickshell
import "TopBar"
import "PointDock"

Scope {
    id: app

    property int pointDockMod: 0
    property int barMod: 1
    property var mode: barMod // pointDockMod OR barMod

    Bar {
        visible: app.mode == app.barMod
    }

    Dock {
        visible: app.mode == app.pointDockMod
    }
}
