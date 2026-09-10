pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property var activePrefix: {
        if (query.length === 0)
            return null;
        for (var i = 0; i < prefixes.length; i++)
            if (prefixes[i].char === query[0])
                return prefixes[i];
        return null;
    }
    // window size.
    readonly property int defaultHeight: 536
    // The WlSessionLock scope from shell.qml, so PowerView can lock the screen.
    property var lockRef: null
    readonly property int paletteRadius: Globals.paletteRadius
    readonly property int paletteWidth: 720

    // Search prefixes. Empty query shows the current view; a bare word searches
    // widgets (commands view); a prefix routes to a specialized search view.
    readonly property var prefixes: [
        {
            char: ":",
            view: "apps"
        },
        {
            char: "?",
            view: "web"
        },
        {
            char: "!",
            view: "shell"
        }
    ]
    property string query: ""

    // True while the palette shows one of the prefix-search results views.
    // Those stay instantiated (see Palette.qml); only panel views swap.
    readonly property bool searchMode: viewId === "apps" || viewId === "web" || viewId === "shell" || viewId === "commands"

    // The query with its prefix stripped and trimmed.
    readonly property string searchText: activePrefix ? query.substring(1).trim() : query.trim()
    // Which view the current query points at ("commands" when unprefixed).
    readonly property string searchView: activePrefix ? activePrefix.view : (query.length > 0 ? "commands" : "")
    property string viewId: "home"

    property bool visible: false

    // Every palette view reachable from Home tiles or the command search.
    readonly property var views: [
        {
            id: "home",
            title: "Home",
            icon: "home",
            keywords: "start status dashboard overview glance media music player mpris playback"
        },
        {
            id: "apps",
            title: "Apps",
            icon: "grid",
            keywords: "applications launcher programs software"
        },
        {
            id: "mixer",
            title: "Mixer",
            icon: "speaker",
            keywords: "volume sound mixer mute per-app apps output device sink pavucontrol"
        },
        {
            id: "bluetooth",
            title: "Bluetooth",
            icon: "bluetooth",
            keywords: "devices pair headset"
        },
        {
            id: "network",
            title: "Network",
            icon: "wifi-on",
            keywords: "wifi wi-fi wireless ethernet ssid"
        },
        {
            id: "battery",
            title: "Battery",
            icon: "battery",
            keywords: "power profile energy hypridle"
        },
        {
            id: "notifications",
            title: "Notifications",
            icon: "bell",
            keywords: "alerts dnd do not disturb bell center"
        },
        {
            id: "tailscale",
            title: "Tailscale",
            icon: "tailscale",
            keywords: "vpn exit node mesh taildrop"
        },
        {
            id: "power",
            title: "Power",
            icon: "power",
            keywords: "lock logout reboot shutdown session off"
        },
        {
            id: "clock",
            title: "Clock",
            icon: "calendar",
            keywords: "time date calendar"
        },
        {
            id: "remote",
            title: "Remote",
            icon: "remote",
            keywords: "ssh remote hosts kamina genome yoko buxtorf-synology tmux sessions"
        }
    ]

    function back() {
        if (query.length > 0) {
            query = "";
            viewId = "home";
            return;
        }
        if (viewId !== "home") {
            viewId = "home";
            return;
        }
        close();
    }
    function close() {
        visible = false;
        viewId = "home";
        query = "";
    }

    // Fuzzy scoring, shared by the command and app searches. Operates on
    // PREPARED keys (lowercased name + word array, built once per entry), so
    // scoring a query does zero toLowerCase/split allocations.
    function getMatchScore(name, s) {
        if (name.startsWith(s))
            return 3;
        if (name.includes(s))
            return 2;
        if (name.includes(s[0]))
            return 1;
        return 0;
    }
    function getPreparedScore(name, words, s) {
        if (!s)
            return 1;
        let score = getMatchScore(name, s);
        for (let i = 0; i < words.length; i++) {
            const w = getMatchScore(words[i], s);
            if (w > score)
                score = w;
        }
        return score;
    }
    function lockScreen() {
        if (root.lockRef)
            root.lockRef.locked = true;
        Globals.playSound(Globals.sounds.lock);
        root.close();
    }
    function logout() {
        Quickshell.execDetached({
            command: ["loginctl", "terminate-user", Quickshell.env("USER")]
        });
        root.close();
    }
    function navigate(view) {
        // Clear the query BEFORE setting the view: query="" routes home via
        // setQuery, so assigning viewId first would get stomped back to home.
        query = "";
        viewId = view;
        visible = true;
        Globals.playSound(Globals.sounds.click);
    }
    function open(view) {
        query = "";
        viewId = view || "home";
        visible = true;
    }
    function reboot() {
        Quickshell.execDetached({
            command: ["systemctl", "reboot"]
        });
        root.close();
    }
    function setQuery(text) {
        query = text;
        // Empty query routes home; non-empty routes to the prefix's view.
        // Guard: an equal assignment still fires changed signals, which would
        // re-run view routing and bindings on every keystroke.
        const target = text.length > 0 ? searchView : "home";
        if (viewId !== target)
            viewId = target;
    }

    // Session actions, shared by the Power view and the Home mini power tile.
    function shutdown() {
        Quickshell.execDetached({
            command: ["systemctl", "poweroff"]
        });
        root.close();
    }
    function toggle(view) {
        if (visible)
            close();
        else
            open(view);
    }
}
