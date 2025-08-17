pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null
    property bool wifiEnabled: true
    readonly property bool scanning: rescanProc.running

    readonly property bool connecting: connectProc.running
    property string ssidConnecting: ""
    property bool errorHappened: false

    property var icon: active?.strengthIcon || "..."

    // bandwidth
    property int historyLength: 20
    property real sent: 0
    property list<real> sentHistory: Array(historyLength).fill(0)
    property real received: 0
    property list<real> receivedHistory: Array(historyLength).fill(0)

    reloadableId: "network"

    function enableWifi(enabled: bool): void {
        const cmd = enabled ? "on" : "off";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function toggleWifi(): void {
        const cmd = wifiEnabled ? "off" : "on";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function rescanWifi(): void {
        rescanProc.running = true;
    }

    function connectToNetwork(ssid: string, password: string): void {
        // TODO: Implement password
        ssidConnecting = ssid
        connectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        connectProc.running = true
    }

    function disconnectFromNetwork(): void {
        if (active) {
            disconnectProc.command = ["nmcli", "connection", "down", active.ssid];
            connectProc.running = true
        }
    }

    function getWifiStatus(): void {
        wifiStatusProc.running = true;
    }


    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }

    Process {
        id: wifiStatusProc

        running: true
        command: ["nmcli", "radio", "wifi"]
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled";
            }
        }
    }

    Process {
        id: enableWifiProc

        onExited: {
            root.getWifiStatus();
            getNetworks.running = true;
        }
    }

    Process {
        id: rescanProc

        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: {
            getNetworks.running = true;
        }
    }

    Process {
        id: connectProc

        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
        stderr: StdioCollector {
            onStreamFinished: {
                root.errorHappened = text.length > 0
                if(root.errorHappened)
                    console.warn("Network connection error:", text)
            }
        }
    }

    Process {
        id: disconnectProc

        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }

    Process {
        id: getNetworks

        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const allNetworks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes" || net[0] === "oui",
                        strength: parseInt(net[1]),
                        frequency: parseInt(net[2]),
                        ssid: net[3],
                        bssid: net[4]?.replace(rep2, ":") ?? "",
                        security: net[5] || ""
                    };
                }).filter(n => n.ssid && n.ssid.length > 0);

                // Group networks by SSID and prioritize connected ones
                const networkMap = new Map();
                for (const network of allNetworks) {
                    const existing = networkMap.get(network.ssid);
                    if (!existing) {
                        networkMap.set(network.ssid, network);
                    } else {
                        // Prioritize active/connected networks
                        if (network.active && !existing.active) {
                            networkMap.set(network.ssid, network);
                        } else if (!network.active && !existing.active) {
                            // If both are inactive, keep the one with better signal
                            if (network.strength > existing.strength) {
                                networkMap.set(network.ssid, network);
                            }
                        }
                        // If existing is active and new is not, keep existing
                    }
                }

                const networks = Array.from(networkMap.values());

                const rNetworks = root.networks;

                const destroyed = rNetworks.filter(rn => !networks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                for (const network of networks) {
                    const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                    if (match) {
                        match.lastIpcObject = network;
                    } else {
                        rNetworks.push(apComp.createObject(root, {
                            lastIpcObject: network
                        }));
                    }
                }
                root.icon = active?.strengthIcon || "..."
            }
        }
    }

    Process {
        id: getBandwidth

        running: true
        command: ["awk", '/:/ {recv += $2; trans += $10} END {printf "%.2f#%.2f", recv/1024/1024, trans/1024/1024}', "/proc/net/dev"]

        stdout: StdioCollector {
            onStreamFinished: {
                const datas = text.trim().split("#")
                root.received = datas[0]
                root.sent = datas[1]

                root.sentHistory.shift()
                root.receivedHistory.shift()

                root.sentHistory.push(root.sent)
                root.receivedHistory.push(root.received)
            }
        }
    }

    Timer {
        interval: 1500

        running: true
        repeat: true

        onTriggered: getBandwidth.running = true
    }


    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property string strengthIcon: (strength > 80) ? "󰤨"
                                             : (strength > 60) ? "󰤥"
                                             : (strength > 40) ? "󰤢"
                                             : (strength > 20) ? "󰤟"
                                             : "󰤯"
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string security: lastIpcObject.security
        readonly property bool isSecure: security.length > 0
    }

    Component {
        id: apComp

        AccessPoint {}
    }
}