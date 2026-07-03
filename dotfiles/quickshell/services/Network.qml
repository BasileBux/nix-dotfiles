pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Networking as Net

Singleton {
    id: root

    readonly property bool wifiEnabled: Net.Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Net.Networking.wifiHardwareEnabled
    readonly property bool scanning: wifiDevice?.scannerEnabled ?? false
    readonly property bool startupFinished: true

    property bool popupVisible: false

    onPopupVisibleChanged: {
        // Stop scanning as soon as the popup is closed.
        if (!popupVisible && wifiDevice) wifiDevice.scannerEnabled = false;
    }

    Timer {
        id: scanStopTimer
        interval: 10000
        onTriggered: {
            if (wifiDevice) wifiDevice.scannerEnabled = false;
        }
    }

    readonly property Net.WifiDevice wifiDevice: {
        const devices = Net.Networking.devices.values;
        for (let i = 0; i < devices.length; ++i) {
            if (devices[i].type === Net.DeviceType.Wifi) return devices[i];
        }
        return null;
    }

    readonly property Net.WiredDevice wiredDevice: {
        const devices = Net.Networking.devices.values;
        for (let i = 0; i < devices.length; ++i) {
            if (devices[i].type === Net.DeviceType.Wired) return devices[i];
        }
        return null;
    }

    readonly property bool ethernetConnected: wiredDevice?.hasLink === true && wiredDevice?.network?.connected === true

    readonly property bool hasActiveConnection: {
        if (wifiDevice) {
            const nets = wifiDevice.networks.values;
            for (let i = 0; i < nets.length; ++i) {
                if (nets[i].connected) return true;
            }
        }
        if (wiredDevice?.network?.connected === true) return true;
        return false;
    }

    readonly property string activeConnectionName: {
        if (wifiDevice) {
            const nets = wifiDevice.networks.values;
            for (let i = 0; i < nets.length; ++i) {
                if (nets[i].connected) return nets[i].name;
            }
        }
        if (wiredDevice?.network?.connected === true) return wiredDevice.network.name;
        return "";
    }

    function toggleWifi(): void {
        Net.Networking.wifiEnabled = !Net.Networking.wifiEnabled;
    }

    function rescanWifi(): void {
        if (!wifiDevice) return;
        wifiDevice.scannerEnabled = true;
        scanStopTimer.restart();
    }
}
