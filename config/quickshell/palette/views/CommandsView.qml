import Quickshell
import Quickshell.Io
import QtQuick
import "../widgets" as PWidgets
import "../../services" as Services
import "../.."

// Default search: palette views + quick actions. Shown when the query has no prefix.
Item {
    id: root

    readonly property var actions: [
        {
            title: "Lock screen",
            icon: "lock",
            keywords: "lock screen session sleep",
            exec: () => {
                if (PaletteState.lockRef)
                    PaletteState.lockRef.locked = true;
                Globals.playSound(Globals.sounds.lock);
                PaletteState.close();
            }
        },
        {
            title: "Log out",
            icon: "logout",
            keywords: "logout session exit leave",
            exec: () => {
                Quickshell.execDetached({
                    command: ["loginctl", "terminate-user", Quickshell.env("USER")]
                });
                PaletteState.close();
            }
        },
        {
            title: "Reboot",
            icon: "reboot",
            keywords: "reboot restart system",
            exec: () => {
                Quickshell.execDetached({
                    command: ["systemctl", "reboot"]
                });
                PaletteState.close();
            }
        },
        {
            title: "Shut down",
            icon: "shutdown",
            keywords: "shutdown poweroff power off halt",
            exec: () => {
                Quickshell.execDetached({
                    command: ["systemctl", "poweroff"]
                });
                PaletteState.close();
            }
        },
        {
            title: "Toggle Do Not Disturb",
            icon: "moon",
            keywords: "dnd do not disturb notifications silent",
            exec: () => {
                Services.Notifications.doNotDisturb = !Services.Notifications.doNotDisturb;
                PaletteState.close();
            }
        },
        {
            title: "Toggle Wi-Fi",
            icon: "wifi-on",
            keywords: "wifi wi-fi wireless toggle network",
            exec: () => {
                Services.Network.toggleWifi();
                PaletteState.close();
            }
        },
        {
            title: "Mute audio",
            icon: "muted",
            keywords: "mute volume sound audio",
            exec: () => {
                Services.Audio.toggleMute();
                PaletteState.close();
            }
        },
        {
            title: "Power profile: Eco",
            icon: "leaf",
            keywords: "power profile eco quiet battery saver",
            exec: () => root.setProfile(Machines.current.ecoCommand)
        },
        {
            title: "Power profile: Balanced",
            icon: "balance",
            keywords: "power profile balanced",
            exec: () => root.setProfile(Machines.current.balancedCommand)
        },
        {
            title: "Power profile: Performance",
            icon: "rocket",
            keywords: "power profile performance boost",
            exec: () => root.setProfile(Machines.current.performanceCommand)
        },
        {
            title: "Web search",
            icon: "globe",
            keywords: "web search browser internet duckduckgo",
            exec: () => PaletteState.setQuery("?")
        },
        {
            title: "Shell command",
            icon: "terminal",
            keywords: "shell command run execute terminal",
            exec: () => PaletteState.setQuery("!")
        }
    ]

    // Search keys precomputed once: rebuild() then only scores + sorts.
    readonly property var base: {
        const views = PaletteState.views.map(v => ({
                    kind: "view",
                    id: v.id,
                    title: v.title,
                    icon: v.icon,
                    name: v.title.toLowerCase(),
                    words: v.keywords.toLowerCase().split(" ").filter(w => w.length > 0)
                }));
        const actions = root.actions.map(a => ({
                    kind: "action",
                    exec: a.exec,
                    title: a.title,
                    icon: a.icon,
                    name: a.title.toLowerCase(),
                    words: a.keywords.toLowerCase().split(" ").filter(w => w.length > 0)
                }));
        return views.concat(actions);
    }
    property var entries: []

    function activate(index) {
        const entry = root.entries[index];
        if (!entry)
            return;
        if (entry.kind === "view")
            PaletteState.navigate(entry.id);
        else
            entry.exec();
    }
    function handleKey(event) {
        list.handleKey(event);
    }
    function rebuild() {
        const s = PaletteState.searchText.toLowerCase();
        root.entries = root.base.map(e => ({
                    e: e,
                    score: PaletteState.getPreparedScore(e.name, e.words, s)
                })).filter(x => x.score > 0).sort((a, b) => b.score - a.score || a.e.title.localeCompare(b.e.title)).map(x => x.e);
    }
    function setProfile(command) {
        profileProc.command = command;
        profileProc.running = true;
        PaletteState.close();
    }

    Component.onCompleted: rebuild()

    Connections {
        function onSearchTextChanged() {
            root.rebuild();
        }

        target: PaletteState
    }
    Process {
        id: profileProc

        running: false
    }
    PWidgets.Surface {
        anchors.fill: parent

        PWidgets.ResultList {
            id: list

            anchors.fill: parent
            emptyCaption: "Try : for apps, ? for the web, ! for the shell"
            emptyIcon: "search"
            emptyTitle: "No matching widgets"
            // ResultList drops non-primitive roles (exec, id, ...); the row only
            // shows title/icon/caption.
            entries: root.entries.map(e => ({
                        title: e.title,
                        icon: e.icon,
                        caption: e.kind === "view" ? "Panel" : "Action"
                    }))

            delegate: PWidgets.Row {
                caption: model.caption
                icon: model.icon
                selected: ListView.view.hovered === index
                title: model.title

                onClicked: ListView.view.activated(index)
                onHover: ListView.view.hovered = index
            }

            onActivated: index => root.activate(index)
        }
    }
}
