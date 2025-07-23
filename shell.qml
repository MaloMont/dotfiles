import "PointDock"
import "TopBar"
import Quickshell

Scope {
    id: app

    property int pointDockMod: 0
    property int barMod: 1
    property var mode: pointDockMod // pointDockMod OR barMod

    property var bar: Bar {
        visible: app.mode == app.barMod
    }

    property var dock: Dock {
        visible: app.mode == app.pointDockMod
    }
}
