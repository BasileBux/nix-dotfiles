import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import ".."
import "views" as Views

PanelWindow {
    id: root

    function handleKey(event) {
        // Route to whichever view is showing; all views are permanently
        // instantiated and just flip visibility.
        if (PaletteState.searchMode) {
            for (let i = 0; i < searchHost.children.length; i++) {
                const v = searchHost.children[i];
                if (v.visible && v.handleKey) {
                    v.handleKey(event);
                    return;
                }
            }
            return;
        }
        if (PaletteState.viewId === "home") {
            if (homeView.handleKey)
                homeView.handleKey(event);
            return;
        }
        for (let i = 0; i < panelHost.children.length; i++) {
            const v = panelHost.children[i];
            if (v.visible && v.handleKey) {
                v.handleKey(event);
                return;
            }
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:palette"
    aboveWindows: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    // Fixed height: every view gets the same window size, content adapts.
    implicitHeight: PaletteState.defaultHeight
    implicitWidth: PaletteState.paletteWidth
    // Always mapped: quickshell destroys the backing window of a hidden
    // layer-shell surface, and recreating it costs ~300ms per open (GL context,
    // scene graph, textures, glyphs — measured with QSG_RENDER_TIMING). Hiding
    // instead empties the input region, releases keyboard focus and fades the
    // content; the warm window then shows in about one frame.
    visible: true
    focusable: PaletteState.visible
    mask: PaletteState.visible ? maskAll : maskNone

    // Whole-window input region while shown; nothing (fully click-through,
    // invisible overlay) while hidden.
    Region {
        id: maskAll

        item: root.contentItem
    }
    Region {
        id: maskNone
    }

    HyprlandFocusGrab {
        id: grab

        windows: [root]

        onCleared: {
            if (PaletteState.visible)
                PaletteState.close();
        }
    }
    // All visible content, grouped so hiding is a single opacity flip. The
    // items stay instantiated and in the scene graph — nothing is rebuilt on
    // the next open.
    Item {
        id: content

        anchors.fill: parent
        // No show/hide transition on purpose: the palette must be on screen in a
        // frame. Animated feedback belongs to hover/press inside the surface.
        opacity: PaletteState.visible ? 1 : 0

        Rectangle {
            id: glass

            anchors.fill: parent
            border.color: Qt.rgba(1, 1, 1, 0.10)
            border.width: 1
            color: Globals.surfaceBackground
            radius: PaletteState.paletteRadius

            // Specular wash: a light top edge and a darkened bottom, so the
            // glass has a direction instead of being a flat tint.
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        color: Qt.rgba(1, 1, 1, 0.03)
                        position: 0.0
                    }
                    GradientStop {
                        color: Qt.rgba(1, 1, 1, 0.0)
                        position: 0.40
                    }
                    GradientStop {
                        color: Qt.rgba(0, 0, 0, 0.14)
                        position: 1.0
                    }
                }
                radius: parent.radius
            }
            TapHandler {
                onTapped: searchBar.forceFocus()
            }
        }
        SearchBar {
            id: searchBar

            onKeyForwarded: event => root.handleKey(event)

            anchors {
                left: parent.left
                margins: Globals.margin
                right: parent.right
                top: parent.top
            }
        }

        // Search views stay instantiated for the palette's whole lifetime: swapping
        // them through a Loader on every query↔empty transition is what made typing
        // and erasing hitch. Same for HomeView, the query↔empty bookend.
        Item {
            id: searchHost

            clip: true
            visible: PaletteState.searchMode

            anchors {
                bottom: parent.bottom
                bottomMargin: Globals.margin
                left: parent.left
                leftMargin: Globals.margin
                right: parent.right
                rightMargin: Globals.margin
                top: searchBar.bottom
                topMargin: Globals.margin
            }
            Views.AppsView {
                anchors.fill: parent
                visible: PaletteState.viewId === "apps"
            }
            Views.CommandsView {
                anchors.fill: parent
                visible: PaletteState.viewId === "commands"
            }
            Views.WebView {
                anchors.fill: parent
                visible: PaletteState.viewId === "web"
            }
            Views.ShellView {
                anchors.fill: parent
                visible: PaletteState.viewId === "shell"
            }
        }
        Views.HomeView {
            id: homeView

            clip: true
            visible: PaletteState.viewId === "home"

            anchors {
                bottom: parent.bottom
                bottomMargin: Globals.margin
                left: parent.left
                leftMargin: Globals.margin
                right: parent.right
                rightMargin: Globals.margin
                top: searchBar.bottom
                topMargin: Globals.margin
            }
        }

        // Panel views (audio, network, power, …): permanently instantiated like the
        // search views. The old Loader destroyed and recreated a view on every
        // close (close() resets viewId to home) and on every panel→panel
        // navigation, re-running Component.onCompleted each time.
        Item {
            id: panelHost

            clip: true
            visible: !PaletteState.searchMode && PaletteState.viewId !== "home"

            anchors {
                bottom: parent.bottom
                bottomMargin: Globals.margin
                left: parent.left
                leftMargin: Globals.margin
                right: parent.right
                rightMargin: Globals.margin
                top: searchBar.bottom
                topMargin: Globals.margin
            }
            Views.MixerView {
                anchors.fill: parent
                visible: PaletteState.viewId === "mixer"
            }
            Views.BluetoothView {
                anchors.fill: parent
                visible: PaletteState.viewId === "bluetooth"
            }
            Views.NetworkView {
                anchors.fill: parent
                visible: PaletteState.viewId === "network"
            }
            Views.BatteryView {
                anchors.fill: parent
                visible: PaletteState.viewId === "battery"
            }
            Views.NotificationsView {
                anchors.fill: parent
                visible: PaletteState.viewId === "notifications"
            }
            Views.TailscaleView {
                anchors.fill: parent
                visible: PaletteState.viewId === "tailscale"
            }
            Views.PowerView {
                anchors.fill: parent
                visible: PaletteState.viewId === "power"
            }
            Views.ClockView {
                anchors.fill: parent
                visible: PaletteState.viewId === "clock"
            }
            Views.RemoteView {
                id: remoteView

                anchors.fill: parent
                visible: PaletteState.viewId === "remote"
            }
        }
    }
    Connections {
        function onQueryChanged() {
            searchBar.syncQuery();
        }
        function onVisibleChanged() {
            if (PaletteState.visible) {
                // Small delay before grabbing focus: kept from the mapped-on-demand
                // days; harmless now that the layer is always mapped.
                focusTimer.restart();
            } else {
                grab.active = false;
            }
        }

        target: PaletteState
    }
    Timer {
        id: focusTimer

        interval: 10
        repeat: false

        onTriggered: {
            grab.active = true;
            searchBar.forceFocus();
        }
    }
    GlobalShortcut {
        description: "Toggle the command palette on its Home view"
        name: "palette"

        onPressed: PaletteState.toggle()
    }
    GlobalShortcut {
        description: "Open the Power view (lock, logout, reboot, shutdown)"
        // Kept the historical name: Super+Alt+L now opens the palette's Power view.
        name: "lock"

        onPressed: PaletteState.open("power")
    }
    GlobalShortcut {
        description: "Toggle the Remote ssh view"
        name: "remote"

        onPressed: PaletteState.toggle("remote")
    }

    // Direct menu opens without a dedicated global shortcut, e.g.:
    //   hyprctl dispatch exec quickshell ipc call palette openView network
    IpcHandler {
        function openView(view: string): void {
            PaletteState.open(view);
        }
        // Open the Remote view directly at a host's session picker, e.g.:
        //   quickshell ipc call palette openRemoteHost kamina
        function openRemoteHost(host: string): void {
            remoteView.openHostNamed(host);
        }
        function setQuery(q: string): void {
            PaletteState.setQuery(q);
        }
        function toggleView(view: string): void {
            PaletteState.toggle(view);
        }

        target: "palette"
    }
}
