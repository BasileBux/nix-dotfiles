import Quickshell
import QtQuick
import "../widgets" as PWidgets
import "../.."

// "?" prefix — web search, opens unduck.link (Google front-end) in the browser.
Item {
    id: root

    readonly property string query: PaletteState.searchText

    function activate() {
        if (!root.query)
            return;
        Quickshell.execDetached({
            command: [Globals.browser, "-new-tab", "https://unduck.link?q=" + root.query],
            workingDirectory: "/",
            environment: Globals.cleanEnv
        });
        PaletteState.close();
    }
    function handleKey(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.activate();
            event.accepted = true;
        }
    }

    PWidgets.Surface {
        anchors.fill: parent

        PWidgets.Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            caption: "unduck.link"
            height: 48
            icon: "globe"
            selected: true
            title: root.query ? "Search the web for \u201C" + root.query + "\u201D" : "Search the web"
            visible: root.query !== ""

            onClicked: root.activate()
        }
        PWidgets.EmptyState {
            anchors.centerIn: parent
            caption: "Type a query, press Enter"
            icon: "globe"
            title: "Search the web"
            visible: !root.query
        }
    }
}
