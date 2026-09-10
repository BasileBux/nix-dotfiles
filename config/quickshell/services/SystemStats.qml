pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// btop-lite for the battery view: one Process samples /proc, thermal zones
// and the root filesystem per tick, everything parsed in apply(). Polls only
// while a visible view sets `polling`.
Singleton {
    id: root

    // All-core usage, 0..1 (second sample onward; first tick has no delta yet)
    readonly property real cpu: _cpuUsage
    // Per-core usage, 0..1
    readonly property var cores: _coreUsage
    readonly property real diskPct: diskTotalGb > 0 ? diskUsedGb / diskTotalGb : 0
    property real diskTotalGb: 0
    property real diskUsedGb: 0
    readonly property bool hasTemp: tempZones.length > 0
    // RAM, available-based like btop (what the OOM killer actually sees)
    property real load1: 0
    property real load15: 0
    property real load5: 0
    readonly property real memPct: memTotalGb > 0 ? memUsedGb / memTotalGb : 0
    property real memTotalGb: 0
    property real memUsedGb: 0
    property bool polling: false
    // Hottest thermal zone, °C
    readonly property real tempC: {
        var t = 0;
        for (var i = 0; i < tempZones.length; i++)
            t = Math.max(t, tempZones[i]);
        return t;
    }
    property var tempZones: []
    property real uptimeSec: 0
    readonly property string uptimeText: {
        var s = Math.floor(uptimeSec);
        var d = Math.floor(s / 86400);
        var h = Math.floor((s % 86400) / 3600);
        var m = Math.floor((s % 3600) / 60);
        if (d > 0)
            return d + "d " + h + "h";
        if (h > 0)
            return h + "h " + m + "m";
        return m + "m";
    }

    property real _cpuIdle: 0
    property real _cpuTotal: 0
    property real _cpuUsage: 0
    property var _corePrev: []
    property var _coreUsage: []

    function clamp01(v) {
        return Math.max(0, Math.min(1, v));
    }
    function refresh() {
        sampleTimer.restart();
        sampleProcess.running = true;
    }

    function apply(text) {
        var section = "proc";
        var cpuFields = null;
        var coreFields = [];
        var mem = {};
        var temps = [];
        var diskFields = null;
        var lines = text.split("\n");
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i].trim();
            if (l === "__THERMAL") {
                section = "thermal";
                continue;
            }
            if (l === "__DISK") {
                section = "disk";
                continue;
            }
            if (section === "proc") {
                if (l.indexOf("cpu ") === 0) {
                    cpuFields = l.split(/\s+/).slice(1);
                } else if (/^cpu\d+ /.test(l)) {
                    coreFields.push(l.split(/\s+/).slice(1));
                } else if (l.indexOf("MemTotal:") === 0) {
                    mem.total = parseInt(l.split(/\s+/)[1]);
                } else if (l.indexOf("MemAvailable:") === 0) {
                    mem.avail = parseInt(l.split(/\s+/)[1]);
                } else if (l.indexOf("MemFree:") === 0) {
                    mem.free = parseInt(l.split(/\s+/)[1]);
                } else {
                    // loadavg (5 fields) vs uptime (2); other /proc lines
                    // ("intr 37…", "btime …") fail the parseFloat guard.
                    var f = l.split(/\s+/);
                    if (f.length === 5 && !isNaN(parseFloat(f[0]))) {
                        load1 = parseFloat(f[0]);
                        load5 = parseFloat(f[1]);
                        load15 = parseFloat(f[2]);
                    } else if (f.length === 2 && !isNaN(parseFloat(f[0]))) {
                        uptimeSec = parseFloat(f[0]);
                    }
                }
            } else if (section === "thermal") {
                var t = l.split(/\s+/);
                if (t.length === 2 && !isNaN(parseInt(t[1])))
                    temps.push(parseInt(t[1]) / 1000);
            } else if (/^\S+\s+\d+\s+\d+\s+\d+/.test(l)) {
                diskFields = l.split(/\s+/);
            }
        }

        // CPU deltas: usage = 1 - idle share of the ticks since last sample
        if (cpuFields) {
            var total = 0;
            for (var j = 0; j < cpuFields.length; j++)
                total += parseInt(cpuFields[j]);
            var idle = parseInt(cpuFields[3]) + (cpuFields.length > 4 ? parseInt(cpuFields[4]) : 0);
            if (_cpuTotal > 0 && total > _cpuTotal)
                _cpuUsage = clamp01(1 - (idle - _cpuIdle) / (total - _cpuTotal));
            _cpuTotal = total;
            _cpuIdle = idle;
        }
        var usages = [];
        for (var c = 0; c < coreFields.length; c++) {
            var ct = 0;
            for (var k = 0; k < coreFields[c].length; k++)
                ct += parseInt(coreFields[c][k]);
            var ci = parseInt(coreFields[c][3]) + (coreFields[c].length > 4 ? parseInt(coreFields[c][4]) : 0);
            var prev = _corePrev[c];
            if (prev && ct > prev.total)
                usages.push(clamp01(1 - (ci - prev.idle) / (ct - prev.total)));
            else
                usages.push(0);
            _corePrev[c] = {
                total: ct,
                idle: ci
            };
        }
        _coreUsage = usages;

        if (mem.total > 0) {
            memTotalGb = mem.total / 1048576;
            var avail = !isNaN(mem.avail) ? mem.avail : mem.free ?? 0;
            memUsedGb = (mem.total - avail) / 1048576;
        }
        if (temps.length > 0)
            tempZones = temps;
        if (diskFields) {
            diskTotalGb = parseInt(diskFields[1]) / 1048576;
            diskUsedGb = parseInt(diskFields[2]) / 1048576;
        }
    }

    Timer {
        id: sampleTimer

        interval: 2000
        repeat: true
        running: root.polling

        onTriggered: sampleProcess.running = true
    }
    Process {
        id: sampleProcess

        command: ["sh", "-c", "cat /proc/stat /proc/meminfo /proc/loadavg /proc/uptime; echo __THERMAL; for z in /sys/class/thermal/thermal_zone*; do echo \"$(cat $z/type 2>/dev/null) $(cat $z/temp 2>/dev/null)\"; done; echo __DISK; df -kP / | tail -1"]

        stdout: StdioCollector {
            onStreamFinished: root.apply(this.text)
        }
    }
}
