import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "root:/"


Item {
    property alias panel: wifiPanelModal
    
    function showAt() {
        wifiPanelModal.visible = !wifiPanelModal.visible;
        wifiLogic.refreshNetworks();
    }

    function signalIcon(signal) {
        if (signal >= 80) return "[!]";
        if (signal >= 60) return "[^]";
        if (signal >= 40) return "[~]";
        if (signal >= 20) return "[.]";
        return "[0]";
    }

    Process {
        id: scanProcess
        running: false
        command: ["nmcli", "-t", "-f", "SSID,SECURITY,SIGNAL,IN-USE", "device", "wifi", "list"]
        onRunningChanged: {
            // Removed debug log
        }
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.split("\n");
                var nets = [];
                var seen = {};
                for (var i = 0; i < lines.length; ++i) {
                    var line = lines[i].trim();
                    if (!line) continue;
                    var parts = line.split(":");
                    var ssid = parts[0];
                    var security = parts[1];
                    var signal = parseInt(parts[2]);
                    var inUse = parts[3] === "*";
                    if (ssid) {
                        if (!seen[ssid]) {
                            // First time seeing this SSID
                            nets.push({ ssid: ssid, security: security, signal: signal, connected: inUse });
                            seen[ssid] = true;
                        } else {
                            // SSID already exists, update if this entry has better signal or is connected
                            for (var j = 0; j < nets.length; ++j) {
                                if (nets[j].ssid === ssid) {
                                    // Update connection status if this entry is connected
                                    if (inUse) {
                                        nets[j].connected = true;
                                    }
                                    // Update signal if this entry has better signal
                                    if (signal > nets[j].signal) {
                                        nets[j].signal = signal;
                                        nets[j].security = security;
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
                wifiLogic.networks = nets;
            }
        }
    }

    QtObject {
        id: wifiLogic
        property var networks: []
        property var anchorItem: null
        property real anchorX
        property real anchorY
        property string passwordPromptSsid: ""
        property string passwordInput: ""
        property bool showPasswordPrompt: false
        property string connectingSsid: ""
        property string connectStatus: ""
        property string connectStatusSsid: ""
        property string connectError: ""
        property string connectSecurity: ""
        property var pendingConnect: null
        property string detectedInterface: ""
        property var connectionsToDelete: []

        function profileNameForSsid(ssid) {
            return "quickshell-" + ssid.replace(/[^a-zA-Z0-9]/g, "_");
        }
        function disconnectAndDeleteNetwork(ssid) {
            var profileName = wifiLogic.profileNameForSsid(ssid);
            console.log('WifiPanel: disconnectAndDeleteNetwork called for SSID', ssid, 'profile', profileName);
            disconnectProfileProcess.connectionName = profileName;
            disconnectProfileProcess.running = true;
        }
        function refreshNetworks() {
            scanProcess.running = true;
        }
        function showAt() {
            wifiPanelModal.visible = !wifiPanelModal.visible;
            wifiLogic.refreshNetworks();
        }
        function connectNetwork(ssid, security) {
            wifiLogic.pendingConnect = {ssid: ssid, security: security, password: ""};
            listConnectionsProcess.running = true;
        }
        function submitPassword() {
            wifiLogic.pendingConnect = {ssid: wifiLogic.passwordPromptSsid, security: wifiLogic.connectSecurity, password: wifiLogic.passwordInput};
            listConnectionsProcess.running = true;
        }
        function doConnect() {
            var params = wifiLogic.pendingConnect;
            wifiLogic.connectingSsid = params.ssid;
            if (params.security && params.security !== "--") {
                getInterfaceProcess.running = true;
            } else {
                connectProcess.security = params.security;
                connectProcess.ssid = params.ssid;
                connectProcess.password = params.password;
                connectProcess.running = true;
                wifiLogic.pendingConnect = null;
            }
        }
    }

    // Disconnect, delete profile, refresh
    Process {
        id: disconnectProfileProcess
        property string connectionName: ""
        running: false
        command: ["nmcli", "connection", "down", "id", connectionName]
        onRunningChanged: {
            if (!running) {
                deleteProfileProcess.connectionName = connectionName;
                deleteProfileProcess.running = true;
            }
        }
    }
    Process {
        id: deleteProfileProcess
        property string connectionName: ""
        running: false
        command: ["nmcli", "connection", "delete", "id", connectionName]
        onRunningChanged: {
            if (!running) {
                wifiLogic.refreshNetworks();
            }
        }
    }

    Process {
        id: listConnectionsProcess
        running: false
        command: ["nmcli", "-t", "-f", "NAME,SSID", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                var params = wifiLogic.pendingConnect;
                var lines = text.split("\n");
                var toDelete = [];
                for (var i = 0; i < lines.length; ++i) {
                    var parts = lines[i].split(":");
                    if (parts.length === 2 && parts[1] === params.ssid) {
                        toDelete.push(parts[0]);
                    }
                }
                wifiLogic.connectionsToDelete = toDelete;
                if (toDelete.length > 0) {
                    deleteProfileProcess.connectionName = toDelete[0];
                    deleteProfileProcess.running = true;
                } else {
                    wifiLogic.doConnect();
                }
            }
        }
    }

    // Handles connecting to a Wi-Fi network, with or without password
    Process {
        id: connectProcess
        property string ssid: ""
        property string password: ""
        property string security: ""
        running: false
        command: {
            if (password) {
                return ["nmcli", "device", "wifi", "connect", ssid, "password", password]
            } else {
                return ["nmcli", "device", "wifi", "connect", ssid]
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                wifiLogic.connectingSsid = "";
                wifiLogic.showPasswordPrompt = false;
                wifiLogic.passwordPromptSsid = "";
                wifiLogic.passwordInput = "";
                wifiLogic.connectStatus = "success";
                wifiLogic.connectStatusSsid = connectProcess.ssid;
                wifiLogic.connectError = "";
                wifiLogic.refreshNetworks();
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                wifiLogic.connectingSsid = "";
                wifiLogic.showPasswordPrompt = false;
                wifiLogic.passwordPromptSsid = "";
                wifiLogic.passwordInput = "";
                wifiLogic.connectStatus = "error";
                wifiLogic.connectStatusSsid = connectProcess.ssid;
                wifiLogic.connectError = text;
            }
        }
    }

    // Finds the correct Wi-Fi interface for connection
    Process {
        id: getInterfaceProcess
        running: false
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.split("\n");
                for (var i = 0; i < lines.length; ++i) {
                    var parts = lines[i].split(":");
                    if (parts[1] === "wifi" && parts[2] !== "unavailable") {
                        wifiLogic.detectedInterface = parts[0];
                        break;
                    }
                }
                if (wifiLogic.detectedInterface) {
                    var params = wifiLogic.pendingConnect;
                    addConnectionProcess.ifname = wifiLogic.detectedInterface;
                    addConnectionProcess.ssid = params.ssid;
                    addConnectionProcess.password = params.password;
                    addConnectionProcess.profileName = wifiLogic.profileNameForSsid(params.ssid);
                    addConnectionProcess.security = params.security;
                    addConnectionProcess.running = true;
                } else {
                    wifiLogic.connectStatus = "error";
                    wifiLogic.connectStatusSsid = wifiLogic.pendingConnect.ssid;
                    wifiLogic.connectError = "No Wi-Fi interface found.";
                    wifiLogic.connectingSsid = "";
                    wifiLogic.pendingConnect = null;
                }
            }
        }
    }

    // Adds a new Wi-Fi connection profile
    Process {
        id: addConnectionProcess
        property string ifname: ""
        property string ssid: ""
        property string password: ""
        property string profileName: ""
        property string security: ""
        running: false
        command: {
            var cmd = ["nmcli", "connection", "add", "type", "wifi", "ifname", ifname, "con-name", profileName, "ssid", ssid];
            if (security && security !== "--") {
                cmd.push("wifi-sec.key-mgmt");
                cmd.push("wpa-psk");
                cmd.push("wifi-sec.psk");
                cmd.push(password);
            }
            return cmd;
        }
        stdout: StdioCollector {
            onStreamFinished: {
                upConnectionProcess.profileName = addConnectionProcess.profileName;
                upConnectionProcess.running = true;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                upConnectionProcess.profileName = addConnectionProcess.profileName;
                upConnectionProcess.running = true;
            }
        }
    }

    // Brings up the new connection profile and finalizes connection state
    Process {
        id: upConnectionProcess
        property string profileName: ""
        running: false
        command: ["nmcli", "connection", "up", "id", profileName]
        stdout: StdioCollector {
            onStreamFinished: {
                wifiLogic.connectingSsid = "";
                wifiLogic.showPasswordPrompt = false;
                wifiLogic.passwordPromptSsid = "";
                wifiLogic.passwordInput = "";
                wifiLogic.connectStatus = "success";
                wifiLogic.connectStatusSsid = wifiLogic.pendingConnect ? wifiLogic.pendingConnect.ssid : "";
                wifiLogic.connectError = "";
                wifiLogic.refreshNetworks();
                wifiLogic.pendingConnect = null;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                wifiLogic.connectingSsid = "";
                wifiLogic.showPasswordPrompt = false;
                wifiLogic.passwordPromptSsid = "";
                wifiLogic.passwordInput = "";
                wifiLogic.connectStatus = "error";
                wifiLogic.connectStatusSsid = wifiLogic.pendingConnect ? wifiLogic.pendingConnect.ssid : "";
                wifiLogic.connectError = text;
                wifiLogic.pendingConnect = null;
            }
        }
    }




    /* ============================= */



    MarginWrapperManager {
        margin: 0
    }

    // Wifi button (no background card)
    Rectangle {
        id: wifiButton

        implicitWidth: 20
        implicitHeight: 20
        radius: 18

        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: " "
            font.family: "ComicShannsMono Nerd Font"
            font.pointSize: Theme.fontSize
            color: wifiButtonArea.containsMouse
                ? Theme.textFocused
                : Theme.text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            id: wifiButtonArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                console.log("cliclic") // TODO
                if(wifiPanelModal.visible)
                    wifiPanelModal.visible = false
                else
                    wifiLogic.showAt()
            }
        }
    }

    PanelWindow {
        id: wifiPanelModal

        implicitWidth: 480
        implicitHeight: 800

        anchors.top: true
        anchors.right: true
        margins.right: 0
        margins.top: 0

        visible: false
        color: "transparent"

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive // every keyboard inputs goes onto this panel

        Component.onCompleted: {
            wifiLogic.refreshNetworks()
        }

        Rectangle {
            anchors.fill: parent
            color: "#FFF" // panel background
            radius: 24

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15 // panel margin
                spacing: 0

                // title
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    Layout.preferredHeight: 48
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Text {
                        text: "wifi"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 32
                        color: "#0FF"
                    }
                    Text {
                        text: "Wi-Fi"
                        font.pixelSize: 26
                        font.bold: true
                        color: "#F0F"
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: closeButtonArea.containsMouse ? "#FF0" : "transparent"
                        border.color: "#FF0"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "close"
                            font.family: closeButtonArea.containsMouse ? "Material Symbols Rounded" : "Material Symbols Outlined"
                            font.pixelSize: 20
                            color: closeButtonArea.containsMouse ? Theme.textFocused : Theme.text
                        }
                        MouseArea {
                            id: closeButtonArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: wifiPanelModal.visible = false
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                // separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#000000"
                    opacity: 0.12
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 640
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: 0
                                                // idk
                    color: "#FF0"
                    border.color: "#F00"
                    border.width: 1
                    radius: 18

                    Rectangle {
                        id: bg
                        anchors.fill: parent
                        color: "#CCC"
                        radius: 12
                        border.width: 1
                        border.color: "#FFF"
                        z: 0
                    }

                    Rectangle {
                        id: header
                    }

                    Rectangle {
                        id: listContainer

                        anchors.top: header.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        anchors.margins: 15 // bg-devices gap

                        color: "transparent"

                        clip: true

                        ListView {
                            id: networkListView
                            anchors.fill: parent
                            spacing: 30
                            boundsBehavior: Flickable.StopAtBounds

                            model: wifiLogic.networks
                            delegate: Item {
                                id: networkEntry

                                implicitWidth: parent.width
                                implicitHeight: modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt ? 102 : 42

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    // network entry background
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 42
                                        radius: 8

                                        color: modelData.connected
                                            ? Theme.valid
                                            : (networkMouseArea.containsMouse || (modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt) ? Theme.intensity1 : Theme.overlay)

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
                                            spacing: 12

                                            Text {
                                                text: signalIcon(modelData.signal)
                                                font.family: "Material Symbols Outlined"
                                                font.pixelSize: 20
                                                color: networkMouseArea.containsMouse || (modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt)
                                                    ? "#F0F" 
                                                    : (modelData.connected ? "#F0F" : "#F0F")
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2
                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 6
                                                    Text {
                                                        text: modelData.ssid || "Unknown Network"
                                                        color: networkMouseArea.containsMouse || (modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt)
                                                            ? Theme.textFocused
                                                            : Theme.dark_base
                                                        font.pixelSize: 14
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                        Layout.alignment: Qt.AlignVCenter
                                                    }
                                                    Item {
                                                        implicitWidth: 22
                                                        implicitHeight: 22
                                                        visible: wifiLogic.connectStatusSsid === modelData.ssid && wifiLogic.connectStatus !== ""
                                                        RowLayout {
                                                            anchors.fill: parent
                                                            spacing: 2
                                                            Text {
                                                                visible: wifiLogic.connectStatus === "success"
                                                                text: "check_circle"
                                                                font.family: "Material Symbols Outlined"
                                                                font.pixelSize: 18
                                                                color: Theme.valid
                                                                verticalAlignment: Text.AlignVCenter
                                                            }
                                                            Text {
                                                                visible: wifiLogic.connectStatus === "error"
                                                                text: "error"
                                                                font.family: "Material Symbols Outlined"
                                                                font.pixelSize: 18
                                                                color: Theme.error
                                                                verticalAlignment: Text.AlignVCenter
                                                            }
                                                        }
                                                    }
                                                }
                                                Text {
                                                    text: modelData.security && modelData.security !== "--" ? modelData.security : "Open"
                                                    color: networkMouseArea.containsMouse || (modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt)
                                                        ? Theme.textFocused
                                                        : Theme.dark_base
                                                    font.pixelSize: 11
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                }
                                                Text {
                                                    visible: wifiLogic.connectStatusSsid === modelData.ssid && wifiLogic.connectStatus === "error" && wifiLogic.connectError.length > 0
                                                    text: wifiLogic.connectError
                                                    color: Theme.error
                                                    font.pixelSize: 11
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                }
                                            }
                                            Text {
                                                visible: modelData.connected
                                                text: "connected"
                                                color: networkMouseArea.containsMouse || (modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt)
                                                    ? Theme.textFocused
                                                    : Theme.dark_base
                                                font.pixelSize: 11
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                            Item {
                                                        Layout.alignment: Qt.AlignVCenter
                                                        Layout.preferredHeight: 22
                                                        Layout.preferredWidth: 22
                                                        Spinner {
                                                            visible: wifiLogic.connectingSsid === modelData.ssid
                                                            running: wifiLogic.connectingSsid === modelData.ssid
                                                            color: "#F0F"
                                                            anchors.centerIn: parent
                                                            size: 22
                                                        }
                                                    }
                                        }
                                        MouseArea {
                                            id: networkMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (modelData.connected) {
                                                    wifiLogic.disconnectAndDeleteNetwork(modelData.ssid);
                                                } else if (modelData.security && modelData.security !== "--") {
                                                    wifiLogic.passwordPromptSsid = modelData.ssid;
                                                    wifiLogic.passwordInput = "";
                                                    wifiLogic.showPasswordPrompt = true;
                                                    wifiLogic.connectStatus = "";
                                                    wifiLogic.connectStatusSsid = "";
                                                    wifiLogic.connectError = "";
                                                    wifiLogic.connectSecurity = modelData.security;
                                                } else {
                                                    wifiLogic.connectNetwork(modelData.ssid, modelData.security)
                                                }
                                            }
                                        }
                                    }


                                    Rectangle {
                                        visible: modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        radius: 8
                                        color: "transparent"
                                        anchors.leftMargin: 32
                                        anchors.rightMargin: 32
                                        z: 2
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 10
                                            Item {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 36
                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 8
                                                    color: "transparent"
                                                    border.color: passwordField.activeFocus ? "#F0F" : "#F0F"
                                                    border.width: 1
                                                    TextInput {
                                                        id: passwordField
                                                        anchors.fill: parent
                                                        anchors.margins: 12
                                                        text: wifiLogic.passwordInput
                                                        font.pixelSize: 13
                                                        color: "#F00"
                                                        verticalAlignment: TextInput.AlignVCenter
                                                        clip: true
                                                        focus: true
                                                        selectByMouse: true
                                                        activeFocusOnTab: true
                                                        inputMethodHints: Qt.ImhNone
                                                        echoMode: TextInput.Password
                                                        onTextChanged: wifiLogic.passwordInput = text
                                                        onAccepted: wifiLogic.submitPassword()
                                                        MouseArea {
                                                            id: passwordMouseArea
                                                            anchors.fill: parent
                                                            onClicked: passwordField.forceActiveFocus()
                                                        }
                                                    }
                                                }
                                            }
                                            Rectangle {
                                                width: 80
                                                height: 36
                                                radius: 18
                                                color: "#F0F"
                                                border.color: "#F0F"
                                                border.width: 0
                                                opacity: 1.0
                                                Behavior on color { ColorAnimation { duration: 100 } }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: wifiLogic.submitPassword()
                                                    cursorShape: Qt.PointingHandCursor
                                                    hoverEnabled: true
                                                    onEntered: parent.color = Qt.darker("#F0F", 1.1)
                                                    onExited: parent.color = "#F0F"
                                                }
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "Connect"
                                                    color: "#FF0"
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
