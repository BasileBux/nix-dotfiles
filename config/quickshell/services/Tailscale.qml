pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Parsed from `tailscale status --json`
    readonly property bool running: backendState === "Running"
    property string backendState: ""
    property string authUrl: ""

    // One per city from `tailscale exit-node list` (the ACL-filtered list of
    // nodes that can actually be used), online status enriched from status
    // [{ name, ip, online, location }]
    property var exitNodes: []
    property string currentExitNode: ""

    // [{ name, ip, online }] from `tailscale file cp --targets`
    property var fileTargets: []

    readonly property bool busy: actionProcess.running

    readonly property string downloadDir: {
        var dir = Quickshell.env("XDG_DOWNLOAD_DIR");
        if (dir) return dir.replace(/^~\/|^~/, Quickshell.env("HOME") + "/");
        return Quickshell.env("HOME") + "/Downloads";
    }

    property var _peerOnline: ({})
    property var _exitRows: []
    property string _currentExitIp: ""

    // polling only while the tailscale panel is shown (set by TailscalePopup)
    property bool panelVisible: false

    function refresh() {
        statusProcess.running = true;
        exitNodeListProcess.running = true;
        targetsProcess.running = true;
    }

    function applyStatus(text) {
        var d;
        try {
            d = JSON.parse(text);
        } catch (e) {
            return;
        }
        backendState = d.BackendState ?? "";
        authUrl = d.AuthURL ?? "";
        var online = {};
        var currentIp = "";
        var peerMap = d.Peer ?? {};
        for (var k in peerMap) {
            var p = peerMap[k];
            var ip = p.TailscaleIPs ? p.TailscaleIPs[0] : null;
            if (ip) online[ip] = !!p.Online;
            if (p.ExitNode && ip) currentIp = ip;
        }
        if (!currentIp && d.ExitNodeStatus && d.ExitNodeStatus.TailscaleIPs)
            currentIp = d.ExitNodeStatus.TailscaleIPs[0];
        _peerOnline = online;
        _currentExitIp = currentIp;
        rebuildExitNodes();
    }

    function applyExitNodeList(text) {
        var rows = [];
        var lines = text.split(/\r?\n/);
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line.length === 0 || line.charAt(0) === "#") continue;
            var fields = line.split(/\s{2,}/);
            // only rows start with an IP; skips the header
            if (!/^\d+\.\d+\.\d+\.\d+$/.test(fields[0])) continue;
            if (fields.length < 4) continue;
            rows.push({ ip: fields[0], host: fields[1], country: fields[2], city: fields[3] });
        }
        _exitRows = rows;
        rebuildExitNodes();
    }

    function rebuildExitNodes() {
        var nodes = [];
        var current = "";
        for (var i = 0; i < _exitRows.length; i++) {
            var row = _exitRows[i];
            nodes.push({
                name: row.host.split(".")[0],
                ip: row.ip,
                online: _peerOnline[row.ip] ?? false,
                location: row.country + " · " + row.city
            });
            if (row.ip === _currentExitIp) current = row.host.split(".")[0];
        }
        root.exitNodes = nodes;
        root.currentExitNode = current;
    }

    function applyTargets(text) {
        var out = [];
        var lines = text.split(/\r?\n/);
        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].split(/\t/);
            if (parts.length < 2) continue;
            out.push({
                ip: parts[0].trim(),
                name: parts[1].trim(),
                online: lines[i].indexOf("offline") === -1
            });
        }
        root.fileTargets = out;
    }

    function run(args, onDone) {
        actionProcess.onDone = onDone ?? null;
        actionProcess.command = args;
        actionProcess.running = true;
    }

    function toggle() {
        run(running ? ["tailscale", "down"] : ["tailscale", "up"]);
    }

    function setExitNode(entry) {
        // null clears the exit node
        run(["tailscale", "set", "--exit-node=" + (entry ? entry.ip : "")]);
    }

    function receiveFiles(dir, onDone) {
        run(["tailscale", "file", "get", "--conflict=rename", dir], onDone);
    }

    function sendFiles(paths, targetName, onDone) {
        run(["tailscale", "file", "cp"].concat(paths).concat([targetName + ":"]), onDone);
    }

    Process {
        id: statusProcess
        command: ["tailscale", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(this.text)
        }
    }

    Process {
        id: exitNodeListProcess
        command: ["tailscale", "exit-node", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.applyExitNodeList(this.text)
        }
    }

    Process {
        id: targetsProcess
        command: ["tailscale", "file", "cp", "--targets"]
        stdout: StdioCollector {
            onStreamFinished: root.applyTargets(this.text)
        }
    }

    Process {
        id: actionProcess
        property var onDone: null
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                if (actionProcess.onDone && this.text.trim().length > 0)
                    actionProcess.onDone(this.text.trim());
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (actionProcess.onDone && this.text.trim().length > 0)
                    actionProcess.onDone(this.text.trim());
            }
        }
        onExited: root.refresh()
    }

    Timer {
        interval: 5000
        running: root.panelVisible
        repeat: true
        onTriggered: root.refresh()
    }
}
