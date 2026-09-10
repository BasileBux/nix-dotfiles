import QtQuick
import "../.."

// Reusable search-result list: syncs a plain array of display objects into a
// ListModel in place (rows persist, a keystroke only rewrites a few strings),
// owns the Up/Down/Ctrl+P/N/K/J cursor and Enter activation, resets the cursor
// on query change and shows an empty state inside the same surface.
//
// Entries may carry arbitrary string/number/bool properties (functions and
// objects are dropped, they don't survive a ListModel).
ListView {
    id: list

    property string emptyCaption
    property string emptyIcon
    property string emptyTitle
    property var entries: []
    property int hovered: 0

    signal activated(int index)

    function handleKey(event) {
        if (event.key === Qt.Key_Up || ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
            move(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Down || ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
            move(1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            activated(hovered);
            event.accepted = true;
        }
    }
    function move(delta) {
        hovered = Math.max(0, Math.min(hovered + delta, list.entries.length - 1));
        positionViewAtIndex(hovered, ListView.Visible);
    }
    function resetScroll() {
        contentY = 0;
        returnToBounds();
    }
    function sync() {
        while (items.count > list.entries.length)
            items.remove(items.count - 1);
        for (let i = 0; i < list.entries.length; i++) {
            const e = list.entries[i];
            const props = {};
            for (const k in e) {
                const v = e[k];
                if (typeof v === "string" || typeof v === "number" || typeof v === "boolean")
                    props[k] = v;
            }
            if (i < items.count)
                items.set(i, props);
            else
                items.append(props);
        }
    }

    clip: true
    spacing: Globals.space1

    model: ListModel {
        id: items
    }

    Component.onCompleted: sync()
    onEntriesChanged: sync()

    Connections {
        function onSearchTextChanged() {
            list.hovered = 0;
            list.resetScroll();
        }

        // Views stay instantiated while the palette is hidden, so a closed
        // palette would otherwise reopen scrolled to the old position.
        function onVisibleChanged() {
            if (!PaletteState.visible) {
                list.hovered = 0;
                list.resetScroll();
            }
        }

        target: PaletteState
    }
    // The empty state lives inside the same surface as the rows: a zero-result
    // search keeps its hairline and radius instead of turning into raw text.
    EmptyState {
        anchors.centerIn: parent
        caption: list.emptyCaption
        icon: list.emptyIcon
        title: list.emptyTitle
        visible: list.entries.length === 0
    }
}
