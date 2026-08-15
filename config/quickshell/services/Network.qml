pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Networking as Net

Singleton {
    readonly property bool wifiEnabled: Net.Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Net.Networking.wifiHardwareEnabled

    readonly property Net.WifiDevice wifiDevice: {
        const devs = Net.Networking.devices.values;
        for (let i = 0; i < devs.length; ++i) {
            if (devs[i].type === Net.DeviceType.Wifi) return devs[i];
        }
        return null;
    }

    readonly property Net.WiredDevice wiredDevice: {
        const devs = Net.Networking.devices.values;
        for (let i = 0; i < devs.length; ++i) {
            if (devs[i].type === Net.DeviceType.Wired) return devs[i];
        }
        return null;
    }

    readonly property bool ethernetConnected: wiredDevice?.connected === true

    readonly property bool wifiConnected: {
        if (!wifiDevice) return false;
        const nets = wifiDevice.networks.values;
        for (let i = 0; i < nets.length; ++i) {
            if (nets[i].connected) return true;
        }
        return false;
    }

    readonly property string activeSsid: {
        if (!wifiDevice) return "";
        const nets = wifiDevice.networks.values;
        for (let i = 0; i < nets.length; ++i) {
            if (nets[i].connected) return nets[i].name;
        }
        return "";
    }

    readonly property bool scanning: wifiDevice?.scannerEnabled ?? false

    function toggleWifi() {
        Net.Networking.wifiEnabled = !Net.Networking.wifiEnabled;
    }

    function startScan() {
        if (wifiDevice) wifiDevice.scannerEnabled = true;
    }

    function stopScan() {
        if (wifiDevice) wifiDevice.scannerEnabled = false;
    }
}
