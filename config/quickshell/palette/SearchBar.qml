import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "widgets" as PWidgets
import "../widgets" as Widgets

// The input bar. One L1 surface: the bar itself is the field, so there is no
// second recessed rectangle nested inside a card.
PWidgets.Surface {
    id: root

    readonly property string chipLabel: chipLabels[PaletteState.searchView] ?? ""
    readonly property var chipLabels: ({
            apps: "Apps",
            web: "Web",
            shell: "Shell",
            commands: "Widgets"
        })
    readonly property alias input: input

    signal keyForwarded(var event)

    function forceFocus() {
        input.forceActiveFocus();
    }

    // Programmatic query changes (Esc, view actions) sync back into the field.
    function syncQuery() {
        if (input.text !== PaletteState.query)
            input.text = PaletteState.query;
    }

    implicitHeight: 48
    padding: Globals.space2

    RowLayout {
        anchors.fill: parent
        spacing: Globals.space2

        Widgets.TintIcon {
            Layout.preferredHeight: 20
            Layout.preferredWidth: 20
            color: Globals.theme.muted
            name: "search"
        }
        TextField {
            id: input

            readonly property string placeholder: {
                switch (PaletteState.searchView) {
                case "apps":
                    return "Search apps…";
                case "web":
                    return "Search the web…";
                case "shell":
                    return "Run a shell command…";
                default:
                    return "Search widgets…";
                }
            }

            Layout.fillHeight: true
            Layout.fillWidth: true
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.body
            placeholderText: placeholder
            placeholderTextColor: Globals.theme.muted
            verticalAlignment: TextInput.AlignVCenter

            background: Item {}
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape || (event.key === Qt.Key_BracketLeft && (event.modifiers & Qt.ControlModifier))) {
                    PaletteState.back();
                    event.accepted = true;
                    return;
                }
                // Power view owns S/R/O/L: hand them over instead of typing,
                // or they would reroute to the command search.
                if (PaletteState.viewId === "power" && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
                    const k = event.key;
                    if (k === Qt.Key_S || k === Qt.Key_R || k === Qt.Key_O || k === Qt.Key_L) {
                        root.keyForwarded(event);
                        event.accepted = true;
                        return;
                    }
                }
                // Panel views own bare navigation keys: Left/Right step power
                // profiles and the player transport, Tab cycles the audio
                // output, Backspace clears notifications (only when the field
                // is empty — with text in it the field keeps editing). Only
                // forwarded outside search mode so the text field keeps its
                // normal cursor/editing behaviour while searching.
                if (!PaletteState.searchMode) {
                    const k = event.key;
                    if (k === Qt.Key_Left || k === Qt.Key_Right || k === Qt.Key_Tab || (k === Qt.Key_Home && PaletteState.viewId === "clock") || (k === Qt.Key_Backspace && input.text.length === 0)) {
                        root.keyForwarded(event);
                        event.accepted = true;
                        return;
                    }
                }
                // Everything else that is not plain typing goes to the active view:
                // arrows/Ctrl+P/N select, Enter/Shift+Enter activates,
                // Ctrl+letter drives the Home tiles.
                if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_Return || event.key === Qt.Key_Enter || (event.modifiers & Qt.ControlModifier)) {
                    root.keyForwarded(event);
                    event.accepted = true;
                }
            }
            onTextChanged: PaletteState.setQuery(text)
        }

        // Mode chip sits after the field: appearing/disappearing as you type
        // must never shift the search text sideways.
        Rectangle {
            color: Globals.accentFill
            implicitHeight: 20
            implicitWidth: chipText.implicitWidth + Globals.space2 * 2
            radius: height / 2
            visible: root.chipLabel !== ""

            Text {
                id: chipText

                anchors.centerIn: parent
                color: Globals.accent
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.micro
                font.weight: Font.DemiBold
                text: root.chipLabel
            }
        }
        PWidgets.IconButton {
            icon: "cross"
            iconSize: 20
            size: 32
            tooltip: "Clear search"
            visible: input.text.length > 0

            onClicked: {
                PaletteState.back();
                root.forceFocus();
            }
        }
    }
}
