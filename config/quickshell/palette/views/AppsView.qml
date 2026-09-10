import Quickshell
import Quickshell.Widgets
import QtQuick
import "../widgets" as PWidgets
import "../.."

// ":" prefix — application search, ported from the old PopupLauncher.
Item {
    id: root

    // Persistent icon URL cache: resolving an icon theme path per delegate
    // re-bind is wasted work; mutating a var property is fine for a cache.
    readonly property var _iconCache: ({})
    property var applications: DesktopEntries.applications.values.filter(app => !app.noDisplay)

    // Computed, not assigned: assigning an empty result at construction used to
    // break the binding, leaving the list empty forever.
    readonly property var filtered: {
        const s = PaletteState.searchText.toLowerCase();
        if (!s)
            return applications;
        return prepared.map(e => ({
                    e: e,
                    score: PaletteState.getPreparedScore(e.name, e.words, s)
                })).filter(x => x.score > 0).sort((a, b) => b.score - a.score || a.e.app.name.localeCompare(b.e.app.name)).slice(0, 25).map(x => x.e.app);
    }
    // Search keys are computed once per app, not per keystroke: scoring then
    // costs plain string comparisons.
    readonly property var prepared: {
        return applications.map(app => ({
                    app: app,
                    name: (app.name || "").toLowerCase(),
                    words: (app.keywords || []).join(" ").toLowerCase().split(" ").filter(w => w.length > 0)
                }));
    }

    // Display objects for the ResultList (title + cached icon URL).
    readonly property var rows: filtered.map(app => ({
                title: app.name || "Unknown App",
                imageUrl: root.iconUrl(app)
            }))

    function activate(index) {
        const app = root.filtered[index];
        if (!app)
            return;
        // Unset Qt-specific env vars that Quickshell inherits, they can cause
        // version conflicts with apps that bundle their own Qt
        const cleanEnv = Globals.cleanEnv;
        if (app.runInTerminal) {
            Quickshell.execDetached({
                command: [Globals.terminal, "-e", ...app.command],
                workingDirectory: app.workingDirectory,
                environment: cleanEnv
            });
        } else {
            Quickshell.execDetached({
                command: app.command,
                workingDirectory: app.workingDirectory,
                environment: cleanEnv
            });
        }
        Globals.playSound(Globals.sounds.launch);
        PaletteState.close();
    }
    function handleKey(event) {
        list.handleKey(event);
    }
    function iconUrl(app) {
        const id = app?.id || "";
        if (id in _iconCache)
            return _iconCache[id];
        const overrideDir = Qt.resolvedUrl("../../icons/app-fallback/");
        let url;
        if (id === "nemo")
            url = overrideDir + "nemo.png";
        else if (id === "systemsettings" || id === "kdesystemsettings")
            url = overrideDir + "kde-settings.png";
        else
            // check=true: "" for missing theme icons instead of an image:// URL
            // that fails to load ("Could not load icon" warnings on every open).
            url = Quickshell.iconPath(app?.icon, true) || overrideDir + "general.png";
        _iconCache[id] = url;
        return url;
    }

    PWidgets.Surface {
        anchors.fill: parent

        PWidgets.ResultList {
            id: list

            anchors.fill: parent
            emptyCaption: PaletteState.searchText.length > 0 ? "No installed application matches" : "Type :name to search applications"
            emptyIcon: "grid"
            emptyTitle: "No matching apps"
            entries: root.rows

            delegate: PWidgets.Row {
                imageUrl: model.imageUrl
                selected: ListView.view.hovered === index
                title: model.title

                onClicked: ListView.view.activated(index)
                onHover: ListView.view.hovered = index
            }

            onActivated: index => root.activate(index)
        }
    }
}
