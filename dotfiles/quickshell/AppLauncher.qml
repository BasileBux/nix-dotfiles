import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls

PanelWindow {
    id: root
    color: "transparent"
    implicitWidth: Globals.launcherWidth
    implicitHeight: Globals.launcherHeight

    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore

    anchors {
        bottom: true
    }

    function show() {
        launcher.state = "visible";
        launcherFocusGrab.active = true;
        focusPaddingTimer.start();
        appList.positionViewAtBeginning();
        appList.hovered = 0;
        searchInput.forceActiveFocus();
        searchInput.clear();
        return;
    }

    function hide() {
        launcher.state = "hidden";
        launcherFocusGrab.active = false;
        return;
    }

    Item {
        id: launcher
        anchors.bottom: parent.bottom
        implicitWidth: Globals.launcherWidth - Globals.radius * 2
        focus: true

        property var applications: {
            return DesktopEntries.applications.values.filter(app => !app.noDisplay);
        }
        property var filteredApplications: applications

        function submitSelection() {
            let values = launcher.filteredApplications.values;
            if (!values || values.length === 0) {
                values = launcher.filteredApplications;
            }
            const idx = Math.max(0, Math.min(appList.hovered, values.length - 1));
            const app = values[idx];
            runApp(app);
            root.hide();
        }

        function runApp(app: DesktopEntry) {
            if (app.runInTerminal) {
                Quickshell.execDetached({
                    command: [Globals.terminal, "-e", ...app.command],
                    workingDirectory: app.workingDirectory
                });
                return;
            }
            Quickshell.execDetached({
                command: app.command,
                workingDirectory: app.workingDirectory
            });
        }

        function browserSearch(query: string) {
            Quickshell.execDetached({
                command: [Globals.browser, "-new-tab", "https://unduck.link?q=" + query.substring(1)],
                workingDirectory: "/"
            });
            root.hide();
        }

        function getAppScore(app: DesktopEntry, searchText: string): int {
            if (!searchText)
                return 0;
            let score = getMatchScore(app.name, searchText);
            app.keywords.forEach(keyword => {
                const keywordScore = getMatchScore(keyword, searchText);
                if (keywordScore > score) {
                    score = keywordScore;
                }
            });
            return score;
        }

        function getMatchScore(keyword: string, searchText: string): int {
            const name = keyword.toLowerCase();
            const search = searchText.toLowerCase();

            if (name.startsWith(search))
                return 3;
            if (name.includes(search))
                return 2;
            if (name.includes(search[0]))
                return 1;
            return 0;
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.hide();
                return;
            }
            if (event.key === Qt.Key_Up || ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
                if (appList.hovered > 0) {
                    appList.hovered--;
                }
                appList.positionViewAtIndex(appList.hovered, ListView.Visible);
                return;
            }
            if (event.key === Qt.Key_Down || ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
                if (appList.hovered < launcher.filteredApplications.length - 1) {
                    appList.hovered++;
                }
                appList.positionViewAtIndex(appList.hovered, ListView.Visible);

                return;
            }
        }

        state: "hidden"
        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    root.visible: false
                    launcher.implicitHeight: 0
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    root.visible: true
                    launcher.implicitHeight: Globals.launcherHeight
                }
            }
        ]

        transitions: [
            Transition {
                from: "visible"
                to: "hidden"
                SequentialAnimation {
                    NumberAnimation {
                        target: launcher
                        property: "implicitHeight"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: root
                        property: "visible"
                        duration: 0
                    }
                }
            },
            Transition {
                from: "hidden"
                to: "visible"
                SequentialAnimation {
                    NumberAnimation {
                        target: root
                        property: "visible"
                        duration: 0
                    }
                    NumberAnimation {
                        target: launcher
                        property: "implicitHeight"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        ]

        // content
        Component {
            id: appDelegate
            Rectangle {
                id: appItem
                color: appList.hovered === index ? Globals.theme.accent1 : "transparent"
                property DesktopEntry app: modelData
                implicitHeight: 60
                implicitWidth: launcher.implicitWidth - Globals.spacing * 6
                radius: Globals.radius

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        launcher.runApp(appItem.app);
                        root.hide();
                    }
                    onEntered: {
                        appList.hovered = index;
                    }
                }

                RowLayout {
                    id: appDisplay
                    anchors.fill: parent
                    anchors.leftMargin: Globals.spacing
                    anchors.rightMargin: Globals.spacing
                    IconImage {
                        id: appIcon
                        implicitSize: 40
                        asynchronous: true
                        source: {
                            let path = Quickshell.iconPath(appItem?.app.icon);
                            if (path) {
                                return path;
                            }
                            return `file:///run/current-system/sw/share/icons/hicolor/1024x1024/apps/nix-snowflake-white.png`;
                        }
                    }

                    Text {
                        id: appName
                        Layout.fillWidth: true
                        leftPadding: Globals.spacing * 2
                        color: appList.hovered === index ? Globals.theme.background : Globals.theme.foreground
                        font.pixelSize: Globals.fonts.medium
                        font.family: Globals.theme.fontFamily
                        text: appItem.app.name || "Unknown App"
                    }
                }
            }
        }

        ColumnLayout {
            id: appLayout
            anchors {
                fill: parent
                topMargin: Globals.spacing
                leftMargin: Globals.spacing * 3
                rightMargin: Globals.spacing * 3
                bottomMargin: Globals.spacing * 2
            }

            Rectangle {
                color: Globals.theme.background
                implicitHeight: 60
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                z: 1

                TextField {
                    id: searchInput
                    anchors.fill: parent
                    leftPadding: Globals.spacing * 2
                    horizontalAlignment: TextInput.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    color: Globals.theme.foreground
                    font.pointSize: Globals.fonts.medium

                    background: Rectangle {
                        color: "transparent"
                    }
                    placeholderText: "Search..."
                    placeholderTextColor: Globals.theme.muted

                    onTextChanged: {
                        if (text[0] === "?")
                            return;
                        appList.hovered = 0;
                        if (!text) {
                            launcher.filteredApplications = launcher.applications;
                            return;
                        }
                        launcher.filteredApplications = [...launcher.applications].sort((a, b) => {
                            const scoreA = launcher.getAppScore(a, text);
                            const scoreB = launcher.getAppScore(b, text);
                            if (scoreA === scoreB) {
                                return a.name.localeCompare(b.name);
                            }
                            return scoreB - scoreA;
                        });
                    }

                    onAccepted: {
                        if (text[0] === "?") {
                            launcher.browserSearch(text);
                            return;
                        }
                        launcher.submitSelection();
                    }

                    Component.onCompleted: {
                        searchInput.forceActiveFocus();
                    }
                }
            }

            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: launcher.implicitHeight
                spacing: Globals.spacing
                displayMarginBeginning: -(Globals.spacing * 2 + 1)

                property int hovered: 0
                model: launcher.filteredApplications
                delegate: appDelegate
            }
        }

        // Must be drawn underneath everything else
        Shape {
            id: launcherBackground
            anchors.fill: parent
            z: -1

            ShapePath {
                id: laundcherPath
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: Globals.theme.background
                startX: 0
                startY: launcherBackground.height

                PathArc {
                    relativeX: Globals.radius
                    relativeY: -(Globals.radius)
                    radiusX: Globals.radius
                    radiusY: Globals.radius
                    direction: PathArc.Counterclockwise
                }

                PathLine {
                    relativeX: 0
                    relativeY: -(launcherBackground.height - Globals.radius * 2)
                }

                PathArc {
                    relativeX: Globals.radius
                    relativeY: -(Globals.radius)
                    radiusX: Globals.radius
                    radiusY: Globals.radius
                    direction: PathArc.Clockwise
                }

                PathLine {
                    relativeX: launcherBackground.width - Globals.radius * 4
                    relativeY: 0
                }

                PathArc {
                    relativeX: Globals.radius
                    relativeY: Globals.radius
                    radiusX: Globals.radius
                    radiusY: Globals.radius
                    direction: PathArc.Clockwise
                }

                PathLine {
                    relativeX: 0
                    relativeY: launcherBackground.height - Globals.radius * 2
                }

                PathArc {
                    relativeX: Globals.radius
                    relativeY: Globals.radius
                    radiusX: Globals.radius
                    radiusY: Globals.radius
                    direction: PathArc.Counterclockwise
                }
            }
        }
    }

    GlobalShortcut {
        name: "appLauncher"
        onPressed: {
            if (launcher.state === "hidden") {
                root.show();
                return;
            }
            root.hide();
        }
    }

    Timer {
        id: focusPaddingTimer
        interval: 10
        repeat: false
        onTriggered: {
            launcherFocusGrab.active = true;
        }
    }

    HyprlandFocusGrab {
        id: launcherFocusGrab
        windows: [root]
        onCleared: {
            if (launcher.state !== "visible")
                return;
            root.hide();
        }
    }
}
