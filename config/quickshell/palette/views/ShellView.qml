import Quickshell
import QtQuick
import "../widgets" as PWidgets
import "../.."

// "!" prefix — run a shell command, detached or inside kitty.
Item {
    id: root

    readonly property string command: PaletteState.searchText
    readonly property var modes: [
        {
            title: root.command ? "Run \u201C" + root.command + "\u201D" : "Run command",
            caption: "Detached, no terminal",
            terminal: false
        },
        {
            title: "Run in kitty",
            caption: "Interactive terminal session",
            terminal: true
        }
    ]

    function activate(index) {
        if (!root.command)
            return;
        const terminal = root.modes[index]?.terminal ?? false;
        Quickshell.execDetached(terminal ? {
            command: [Globals.terminal, "-e", "sh", "-c", root.command]
        } : {
            command: ["sh", "-c", root.command]
        });
        PaletteState.close();
    }
    function handleKey(event) {
        list.handleKey(event);
    }

    PWidgets.Surface {
        anchors.fill: parent

        PWidgets.ResultList {
            id: list

            anchors.fill: parent
            emptyCaption: "Type a command after !"
            emptyIcon: "terminal"
            emptyTitle: "Run a shell command"
            // Both modes always render: with no command they read as disabled
            // (muted title/caption, no accent bar) instead of being faded out.
            entries: root.modes

            delegate: PWidgets.Row {
                caption: model.caption
                dimmed: !root.command
                height: 48
                icon: "terminal"
                selected: ListView.view.hovered === index && root.command !== ""
                title: model.title

                onClicked: ListView.view.activated(index)
                onHover: ListView.view.hovered = index
            }

            onActivated: index => root.activate(index)
        }
    }
}
