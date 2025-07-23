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
        wifiPanelModal.visible = true;
        wifiLogic.refreshNetworks();
    }

    function signalIcon(signal) {
        if (signal >= 80) return "good  ";
        if (signal >= 60) return "ok    ";
        if (signal >= 40) return "mid   ";
        if (signal >= 20) return "low   ";
        return "zero  ";
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
                    if (parts[1] === "wi.fi" && parts[2] !== "unavailable") {
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




/* ======================== */




    MarginWrapperManager {
        margin: 0
        leftMargin: 5
        rightMargin: 5
    }

    // Wifi button (no background card)
    Rectangle {
        id: wifiButton

        implicitWidth: 20; implicitHeight: 20

        radius: 18
        border.width: 1
        color: wifiButtonArea.containsMouse ? Theme.dark_base : "transparent"

        Text {
            anchors.centerIn: parent
            text: "  "
            font.pointSize: Theme.fontSize
            color: wifiButtonArea.containsMouse ? Theme.textFocused : Theme.text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            id: wifiButtonArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: wifiLogic.showAt()
        }
    }


    PanelWindow {
        id: wifiPanelModal

        implicitWidth: 420
        implicitHeight: 600

        visible: false
        color: "transparent"

        anchors.top: true
        anchors.right: true
        margins.right: 0
        margins.top: 0

        Component.onCompleted: {
            wifiLogic.refreshNetworks()
        }

        Rectangle {
            id: panelBackground

            anchors.fill: parent
            color: Theme.base
            radius: 24

            ColumnLayout {

                anchors.fill: parent
                anchors.margins: 15
                spacing: 0

                // panel title
                RowLayout {
                    spacing: 20

                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    Text {
                        text: "Wifi"
                        font.pointSize: Theme.bigFontSize
                        font.bold: true
                        color: Theme.text
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: 80
                        implicitHeight: 36

                        radius: 18

                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "close"
                            font.pointSize: Theme.bigFontSize
                            color: closeButtonArea.containsMouse ? Theme.textFocused : Theme.overlay
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

                // separation
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.surface
                    opacity: 0.5
                }

                // active zone
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 440
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: 0

                    color: Theme.surface
                    radius: 18

                    border.color: Theme.surface
                    border.width: 1

                    Rectangle {
                        id: bg
                        anchors.fill: parent
                        color: Theme.dark_base
                        radius: 12
                        border.width: 1
                        border.color: Theme.surface
                        z: 0
                    }

                    // wtf is that?
                    Rectangle {
                        id: header
                    }

                    // list of devices container
                    Rectangle {
                        id: listContainer

                        anchors.top: header.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 15

                        color: "transparent"

                        // device list
                        ListView {
                            id: networkListView

                            anchors.fill: parent

                            spacing: 6
                            boundsBehavior: Flickable.StopAtBounds

                            model: wifiLogic.networks

                            // one device
                            delegate: Item {
                                id: networkEntry

                                width: parent.width
                                        // 102 if typing its password, 42 if not
                                height: modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt ? 102 : 42

                                ColumnLayout {

                                    anchors.fill: parent
                                    spacing: 0

                                    // device container
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 42

                                        radius: 8
                                        color: (modelData.connected)
                                            ? Theme.valid
                                            : Theme.surface

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12

                                            spacing: 12

                                            // left wifi icon
                                            Text {
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.alignment: Qt.AlignVCenter

                                                text: signalIcon(modelData.signal)
                                                font.pointSize: Theme.midFontSize
                                                color: modelData.connected 
                                                    ? Theme.dark_base
                                                    : (networkMouseArea.containsMouse || (modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt) ? Theme.textFocused : Theme.text)
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 6

                                                    // ssid
                                                    Text {
                                                        text: modelData.ssid || "Unknown Network"
                                                        color: modelData.connected 
                                                            ? Theme.dark_base
                                                            : (networkMouseArea.containsMouse || (modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt) ? Theme.textFocused : Theme.text)
                                                        font.pointSize: Theme.fontSize
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                        Layout.alignment: Qt.AlignVCenter
                                                    }

                                                    // password prompt
                                                    Item {
                                                        visible: wifiLogic.connectStatusSsid === modelData.ssid && wifiLogic.connectStatus !== ""

                                                        width: 22
                                                        height: 22

                                                        RowLayout {
                                                            anchors.fill: parent
                                                            spacing: 2

                                                            // connected successfully
                                                            Text {
                                                                visible: wifiLogic.connectStatus === "success"
                                                                text: "check_circle"
                                                                font.family: "Material Symbols Outlined"
                                                                font.pointSize: Theme.fontSize
                                                                color: Theme.valid
                                                                verticalAlignment: Text.AlignVCenter
                                                            }

                                                            // failed connecting
                                                            Text {
                                                                visible: wifiLogic.connectStatus === "error"
                                                                text: "error"
                                                                font.family: "Material Symbols Outlined"
                                                                font.pointSize: Theme.fontSize
                                                                color: Theme.error
                                                                verticalAlignment: Text.AlignVCenter
                                                            }
                                                        }
                                                    }
                                                }

                                                // security protocol
                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                    text: modelData.security && modelData.security !== "--" ? modelData.security : "Open"
                                                    color: modelData.connected 
                                                        ? Theme.dark_base
                                                        : (networkMouseArea.containsMouse || (modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt) ? Theme.textFocused : Theme.text)
                                                    font.pointSize: Theme.smallFontSize
                                                }
                                                
                                                // authentification error msg ?
                                                Text {
                                                    visible: wifiLogic.connectStatusSsid === modelData.ssid && wifiLogic.connectStatus === "error" && wifiLogic.connectError.length > 0
                                                    text: wifiLogic.connectError
                                                    color: Theme.intensity3
                                                    font.pixelSize: 11
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                }
                                            }

                                            Text {
                                                visible: modelData.connected
                                                text: "connected"
                                                color: Theme.dark_base
                                                font.pointSize: Theme.fontSize
                                                verticalAlignment: Text.AlignVCenter
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            Item {
                                                Layout.alignment: Qt.AlignVCenter
                                                Layout.preferredHeight: 22
                                                Layout.preferredWidth: 22
                                                Rectangle {
                                                    visible: wifiLogic.connectingSsid === modelData.ssid
                                                    //running: wifiLogic.connectingSsid === modelData.ssid
                                                    color: Theme.intensity1
                                                    anchors.centerIn: parent
                                                    implicitWidth: 22
                                                    implicitHeight: 22
                                                }
                                            }
                                        }

                                        // for the whole device container
                                        MouseArea {
                                            id: networkMouseArea

                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onClicked: {
                                                console.log("clicked", modelData.ssid)
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

                                    // connection-relative
                                    Rectangle {
                                        visible: modelData.ssid === wifiLogic.passwordPromptSsid && wifiLogic.showPasswordPrompt

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        anchors.leftMargin: 32
                                        anchors.rightMargin: 32

                                        radius: 8
                                        color: "transparent"
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
                                                    border.color: passwordField.activeFocus ? "#FF0000" : "#00FFFF"
                                                    border.width: 1

                                                    // password field
                                                    TextInput {
                                                        id: passwordField

                                                        anchors.fill: parent
                                                        anchors.margins: 12
                                                        verticalAlignment: TextInput.AlignVCenter
                                                        clip: true

                                                        text: wifiLogic.passwordInput
                                                        font.pixelSize: 13

                                                        color: Theme.text

                                                        focus: true
                                                        selectByMouse: true
                                                        activeFocusOnTab: true
                                                        activeFocusOnPress: true

                                                        passwordMaskDelay: 300

                                                        inputMethodHints: Qt.ImhNone
                                                        echoMode: TextInput.Password

                                                        onTextChanged: wifiLogic.passwordInput = text

                                                        onAccepted: wifiLogic.submitPassword()

                                                        MouseArea {
                                                            id: passwordMouseArea
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                passwordField.forceActiveFocus()
                                                            }
                                                        }

                                                        onActiveFocusChanged: {
                                                            if (activeFocus){
                                                                if (own.enteredText === ""){
                                                                    // Removing the placeholder
                                                                    lineEdit.text = "";
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                width: 80
                                                height: 36
                                                radius: 18

                                                color: "#FFFF00"
                                                border.color: "#FFFF00"
                                                border.width: 0
                                                opacity: 1.0

                                                Behavior on color { ColorAnimation { duration: 100 } }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    hoverEnabled: true

                                                    onClicked: wifiLogic.submitPassword()

                                                    onEntered: parent.color = Qt.darker("#FF00FF", 1.1)

                                                    onExited: parent.color = "#FF00FF"
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "Connect"
                                                    color: Theme.intensity1
                                                    font.pointSize: Theme.fontSize
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
