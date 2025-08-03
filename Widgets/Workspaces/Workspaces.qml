import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland 
import "root:/"


Row
{
    spacing: 10
    padding: 5

    property var nbWorkspaces: 10
    property var wk: Hyprland.workspaces.values
    property bool loaded: false

    Repeater {
        id: wkIconList
        model: nbWorkspaces

        WorkspaceIcon {
            required property int index
            iWorkspace: index
            focused: Hyprland.focusedMonitor?.activeWorkspace?.id === (index + 1)
        }
    }

    Component.onCompleted: {
        loaded = true
        updateWorkspaces()
    }

    onWkChanged: {
        updateWorkspaces()
    }

    function updateWorkspaces()
    {
        if(!loaded)
            return

        for(var i = 0 ; i < nbWorkspaces ; ++i)
        {
            var cur = wkIconList.itemAt(i)

            cur.occupied = false

            for(var j = 0 ; j < wk.length ; ++j)
                if(i + 1 == wk[j].id)
                    cur.occupied = true
        }
    }
}
