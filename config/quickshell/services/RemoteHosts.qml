pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import ".."

// Fleet state for the Remote palette view: the host list (nix-generated via
// Machines.current.remoteHosts), per-host online status, tmux session
// queries and the launch/power actions.
Singleton {
    id: root

    // Kitty config used for every remote connection (same as the hyprland
    // ssh keybindings).
    readonly property string kittyRemoteConfig: Quickshell.env("HOME") + "/.config/kitty/remote.conf"

    // Sessions of the host currently inspected by the view.
    property var sessions: []
    property string sessionsError: ""
    property string sessionsHost: ""
    property bool sessionsLoading: false

    // name -> "online" | "offline" | "probing", for hosts with no tailscale
    // peer entry (e.g. yoko, which is not on the tailnet). Hosts that do
    // appear in Tailscale.peerStatus are resolved live by statusOf().
    property var statuses: ({})

    readonly property var hosts: Machines.current.remoteHosts ?? []

    function connect(host, session) {
        if (!root.hostHasTmux(host)) {
            root.connectShell(host);
            return;
        }

        // -A attaches to the session, creating it when missing: every
        // connection lands in a tmux session, never a bare shell.
        var remoteCommand = "tmux new-session -A -s " + shellQuote(session);
        Quickshell.execDetached({
            command: [Globals.terminal, "--config", root.kittyRemoteConfig, "kitten", "ssh", "-t", host.target, remoteCommand]
        });
    }
    // Hosts without tmux (buxtorf-synology): plain ssh session in the
    // regular kitty config, no remote.conf.
    function connectShell(host) {
        Quickshell.execDetached({
            command: [Globals.terminal, "kitten", "ssh", host.target]
        });
    }
    function defaultSessionOf(host) {
        return host.defaultSession ?? "main";
    }
    function fetchSessions(host) {
        root.sessionsError = "";
        root.sessionsHost = host.name;
        root.sessions = [];

        if (!root.hostHasTmux(host)) {
            root.sessionsLoading = false;
            return;
        }

        root.sessionsLoading = true;
        sessionsProcess.sshTarget = host.target;
        sessionsProcess.running = false;
        sessionsProcess.command = ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=4", "-o", "ConnectionAttempts=1", host.target, "tmux list-sessions -F '#{session_name}'"];
        sessionsProcess.running = true;
    }
    function hostByName(name) {
        for (var i = 0; i < root.hosts.length; i++)
            if (root.hosts[i].name === name)
                return root.hosts[i];
        return null;
    }
    function hostHasTmux(host) {
        return host.tmux !== false;
    }
    function power(host, action) {
        // -t so the opened terminal shows sudo/systemctl output instead of
        // failing silently in the background.
        Quickshell.execDetached({
            command: [Globals.terminal, "--config", root.kittyRemoteConfig, "kitten", "ssh", "-t", host.target, "sudo systemctl " + action]
        });
    }
    function refresh() {
        Tailscale.refresh();

        // Fresh map object: mutating and reassigning the same reference would
        // not emit a property change, freezing the status dots mid-probe.
        var s = {};
        for (var i = 0; i < root.hosts.length; i++) {
            // Hosts that the tailscale peer list answers for need no probe —
            // usually only yoko (not on the tailnet) gets one.
            if (root.peerStatusFor(root.hosts[i].name) !== null)
                continue;
            s[root.hosts[i].name] = "probing";

            var p = probeComponent.createObject(root, {
                probeHost: root.hosts[i].name
            });
            p.command = ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=8", "-o", "ConnectionAttempts=1", root.hosts[i].target, "true"];
            p.running = true;
        }
        root.statuses = s;
    }
    function peerStatusFor(name) {
        var peers = Tailscale.peerStatus;
        for (var i = 0; i < peers.length; i++)
            if (peers[i].name === name)
                return peers[i].online ? "online" : "offline";
        return null;
    }
    function statusOf(host) {
        return root.peerStatusFor(host.name) ?? root.statuses[host.name] ?? "unknown";
    }

    // SSH concatenates the arguments after the host into a remote shell
    // command. Quote session names before putting them into that command.
    function shellQuote(value) {
        return "'" + value.replace(/'/g, "'\\''") + "'";
    }

    // One throwaway process per probed host, run in parallel: a single slow
    // host (yoko over the public internet) must not delay the others, and a
    // stale sequential chain is what made hosts appear offline.
    Component {
        id: probeComponent

        Process {
            property string probeHost: ""

            command: []
            running: false

            stderr: StdioCollector {
            }

            onExited: function (exitCode) {
                var s = Object.assign({}, root.statuses);
                s[probeHost] = exitCode === 0 ? "online" : "offline";
                root.statuses = s;
                destroy();
            }
        }
    }

    Process {
        id: sessionsProcess

        property string sshTarget: ""

        command: []
        running: false

        stderr: StdioCollector {
            id: sessionsStderr
        }
        stdout: StdioCollector {
            id: sessionsStdout
        }

        onExited: function (exitCode) {
            root.sessionsLoading = false;

            var details = sessionsStderr.text.trim();
            // tmux exits non-zero when no server exists: a normal
            // empty-session state, not a failure.
            var noTmuxServer = /no server running/i.test(details) || (/error connecting to .*tmux.*no such file or directory/i.test(details));

            if (exitCode !== 0 && !noTmuxServer) {
                root.sessionsError = details.length > 0 ? details : "Could not list sessions.";
                return;
            }

            var names = sessionsStdout.text.split(/\r?\n/).map(function (line) {
                return line.trim();
            }).filter(function (line) {
                return line.length > 0;
            });
            names.sort();
            root.sessions = names;

            // The ssh connection obviously works: reflect it in the status
            // even if the reachability probe timed out earlier.
            var s = Object.assign({}, root.statuses);
            s[root.sessionsHost] = "online";
            root.statuses = s;
        }
    }
}
