import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services" as Services
import "../widgets" as PWidgets
import "../../widgets" as Widgets
import "../.."

// Remote fleet menu: pick a host from the nix-generated list, then attach to
// (or create) a tmux session on it. Every connection is tmux — there is no
// plain ssh path; the default session "main" covers most uses.
Item {
    id: root

    property string actionError: ""
    // Two-step confirmation for the power buttons.
    property string armedAction: ""
    readonly property var currentHost: root.level === "sessions" ? (Services.RemoteHosts.hosts[root.hostIndex] ?? null) : null
    readonly property string defaultSession: root.currentHost ? Services.RemoteHosts.defaultSessionOf(root.currentHost) : "main"
    readonly property bool hostHasTmux: root.currentHost ? Services.RemoteHosts.hostHasTmux(root.currentHost) : true
    property int hostIndex: 0
    // "hosts" (fleet list) or "sessions" (picked host's tmux sessions).
    property string level: "hosts"
    property int pickerIndex: 0
    // Existing sessions minus the default one, which has its own primary row.
    readonly property var otherSessions: {
        var list = Services.RemoteHosts.sessions;
        var out = [];
        for (var i = 0; i < list.length; i++)
            if (list[i] !== root.defaultSession)
                out.push(list[i]);
        return out;
    }
    readonly property bool sessionsFailed: Services.RemoteHosts.sessionsError.length > 0

    function activatePickerOption() {
        if (root.pickerIndex === 0) {
            if (root.hostHasTmux)
                root.connectDefault();
            else
                root.connectPlain();
            return;
        }

        if (root.pickerIndex <= root.otherSessions.length) {
            root.connectSession(root.otherSessions[root.pickerIndex - 1]);
            return;
        }

        // Focus the name field first so Enter -> type -> Enter is enough to
        // create a named session. An empty field uses the default name.
        sessionNameField.forceActiveFocus();
    }
    function arm(action) {
        if (root.armedAction === action) {
            root.armedAction = "";
            Services.RemoteHosts.power(root.currentHost, action);
            PaletteState.close();
            return;
        }

        root.armedAction = action;
        armResetTimer.restart();
    }
    function backToHosts() {
        root.level = "hosts";
        root.armedAction = "";
    }
    function connectDefault() {
        Services.RemoteHosts.connect(root.currentHost, root.defaultSession);
        PaletteState.close();
    }
    function connectPlain() {
        Services.RemoteHosts.connectShell(root.currentHost);
        PaletteState.close();
    }
    function connectSession(name) {
        Services.RemoteHosts.connect(root.currentHost, name);
        PaletteState.close();
    }
    function createSession() {
        var session = sessionNameField.text.trim();
        if (session.length === 0)
            session = root.defaultSession;

        if (/[\r\n]/.test(session)) {
            root.actionError = "Session names cannot contain newlines.";
            return;
        }

        root.connectSession(session);
    }

    // Keyboard handling: the search field forwards unhandled keys here.
    function handleKey(event) {
        // Ctrl+N/P: selection, both levels (Up/Down also work).
        if ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_N || event.key === Qt.Key_P)) {
            root.moveSelection(event.key === Qt.Key_N ? 1 : -1);
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
            root.moveSelection(event.key === Qt.Key_Up ? -1 : 1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.level === "hosts")
                root.openHost();
            else
                root.activatePickerOption();
            event.accepted = true;
        } else if (root.level === "sessions" && (event.key === Qt.Key_Backspace || event.key === Qt.Key_Left)) {
            root.backToHosts();
            event.accepted = true;
        }
    }
    function moveSelection(delta) {
        if (root.level === "hosts") {
            root.hostIndex = Math.max(0, Math.min(root.hostIndex + delta, Services.RemoteHosts.hosts.length - 1));
        } else {
            var max = root.hostHasTmux ? root.otherSessions.length + 1 : 0;
            root.pickerIndex = Math.max(0, Math.min(root.pickerIndex + delta, max));
        }
    }
    function openHost() {
        if (Services.RemoteHosts.hosts.length === 0)
            return;

        Services.RemoteHosts.fetchSessions(Services.RemoteHosts.hosts[root.hostIndex]);
        root.level = "sessions";
        root.pickerIndex = 0;
        root.actionError = "";
        root.armedAction = "";
        sessionNameField.text = "";
    }

    // Open the view directly at a host (ipc openRemoteHost, keybindings).
    function openHostNamed(name) {
        PaletteState.open("remote");

        root.openView();
        for (var i = 0; i < Services.RemoteHosts.hosts.length; i++) {
            if (Services.RemoteHosts.hosts[i].name === name) {
                root.hostIndex = i;
                root.openHost();
                return;
            }
        }
    }

    // The view stays instantiated while the palette is hidden: re-run the
    // status refresh every time it is shown, and reset scroll position on
    // hide (it would otherwise reopen at the old position).
    function openView() {
        root.level = "hosts";
        root.hostIndex = 0;
        root.actionError = "";
        root.armedAction = "";
        Services.RemoteHosts.refresh();
    }

    onVisibleChanged: {
        if (visible)
            root.openView();
        else
            hostList.contentY = 0;
    }

    Timer {
        id: armResetTimer

        interval: 3000
        onTriggered: root.armedAction = ""
    }

    Item {
        anchors.fill: parent
        anchors.margins: Globals.space2

        ColumnLayout {
            anchors.fill: parent
            spacing: Globals.space2

            // ---- Level 1: host list ----
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Globals.space1
                visible: root.level === "hosts"

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: Globals.space1
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.title
                    font.weight: Font.DemiBold
                    text: "Remote hosts"
                }
                ListView {
                    id: hostList

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    model: Services.RemoteHosts.hosts
                    spacing: Globals.space1

                    delegate: PWidgets.Row {
                        id: hostDelegate

                        readonly property var host: modelData
                        readonly property string status: Services.RemoteHosts.statusOf(host)

                        height: 44
                        selected: root.hostIndex === index
                        title: hostDelegate.host.name

                        onClicked: {
                            root.hostIndex = index;
                            root.openHost();
                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            color: hostDelegate.status === "online" ? Globals.colors.success : hostDelegate.status === "probing" ? Globals.colors.warning : Globals.theme.muted
                            height: 8
                            radius: 4
                            width: 8
                        }
                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            color: Globals.theme.muted
                            elide: Text.ElideRight
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.micro
                            text: hostDelegate.host.role
                        }
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Globals.space1
                    color: Globals.theme.muted
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.micro
                    text: "↑↓ or Ctrl+N/P · Enter open · ● online  ○ checking"
                }
            }

            // ---- Level 2: host sessions ----
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Globals.space2
                visible: root.level === "sessions"

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    spacing: Globals.space2

                    PWidgets.IconButton {
                        icon: "chevron-left"
                        iconSize: 16
                        size: 28

                        onClicked: root.backToHosts()
                    }
                    Text {
                        color: Globals.theme.foreground
                        elide: Text.ElideRight
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.title
                        font.weight: Font.DemiBold
                        text: root.currentHost ? root.currentHost.name : ""
                    }
                    Rectangle {
                        color: (root.currentHost && Services.RemoteHosts.statusOf(root.currentHost) === "online") ? Globals.colors.success : Globals.theme.muted
                        height: 7
                        radius: 3.5
                        visible: root.currentHost !== null
                        width: 7
                    }
                    Text {
                        Layout.fillWidth: true
                        color: Globals.theme.muted
                        elide: Text.ElideRight
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.micro
                        text: root.currentHost ? root.currentHost.role : ""
                        visible: !Services.RemoteHosts.sessionsLoading
                    }
                    Text {
                        Layout.fillWidth: true
                        color: Globals.theme.muted
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.micro
                        text: "listing sessions…"
                        visible: Services.RemoteHosts.sessionsLoading
                    }
                }
                Widgets.PillButton {
                    Layout.fillWidth: true
                    enabled: !root.sessionsFailed
                    highlighted: true
                    implicitHeight: 40
                    text: root.hostHasTmux ? "Open tmux session \"" + root.defaultSession + "\"" : "Open shell"

                    onClicked: root.hostHasTmux ? root.connectDefault() : root.connectPlain()
                }
                Text {
                    Layout.fillWidth: true
                    color: Globals.theme.muted
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.micro
                    text: "No tmux on this host — opening a plain ssh session."
                    visible: root.level === "sessions" && !root.hostHasTmux
                }
                Text {
                    Layout.fillWidth: true
                    color: Globals.colors.dangerText
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    maximumLineCount: 4
                    text: Services.RemoteHosts.sessionsError
                    visible: root.sessionsFailed
                    wrapMode: Text.Wrap
                }
                Widgets.PillButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Retry"
                    visible: root.sessionsFailed

                    onClicked: root.currentHost && Services.RemoteHosts.fetchSessions(root.currentHost)
                }
                PWidgets.SectionLabel {
                    Layout.topMargin: Globals.space1
                    label: "Sessions"
                    visible: root.hostHasTmux && !root.sessionsFailed
                }
                ListView {
                    id: sessionList

                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 150)
                    clip: true
                    model: root.otherSessions
                    spacing: Globals.space1
                    visible: root.hostHasTmux && !root.sessionsFailed

                    delegate: PWidgets.Row {
                        id: sessionRow

                        height: 40
                        selected: root.pickerIndex === index + 1
                        title: modelData

                        onClicked: root.connectSession(modelData)
                    }
                }
                PWidgets.EmptyState {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Globals.space2
                    caption: "On " + (root.currentHost ? root.currentHost.name : "") + ". Press Enter to open the default one."
                    icon: "remote"
                    title: "No other tmux sessions"
                    visible: root.hostHasTmux && !root.sessionsFailed && !Services.RemoteHosts.sessionsLoading && root.otherSessions.length === 0
                }
                Text {
                    Layout.fillWidth: true
                    color: Globals.colors.dangerText
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    text: root.actionError
                    visible: root.actionError.length > 0
                    wrapMode: Text.Wrap
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Globals.space2
                    visible: root.hostHasTmux && !root.sessionsFailed

                    TextField {
                        id: sessionNameField

                        Layout.fillWidth: true
                        color: Globals.theme.foreground
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.body
                        implicitHeight: 34
                        placeholderText: "New session name (default: " + root.defaultSession + ")"
                        placeholderTextColor: Globals.theme.muted

                        background: Rectangle {
                            border.color: Globals.wellBorder
                            border.width: 1
                            color: Globals.well
                            radius: Globals.radius
                        }

                        onAccepted: root.createSession()
                        onTextChanged: root.actionError = ""
                    }
                    Widgets.PillButton {
                        text: "New tmux"

                        onClicked: root.createSession()
                    }
                }
                RowLayout {
                    spacing: Globals.space2
                    visible: !root.sessionsFailed && root.currentHost && root.currentHost.allowPower === true

                    Widgets.PillButton {
                        confirmed: root.armedAction === "reboot"
                        danger: true
                        text: root.armedAction === "reboot" ? "Confirm reboot?" : "Reboot"

                        onClicked: root.arm("reboot")
                    }
                    Widgets.PillButton {
                        confirmed: root.armedAction === "poweroff"
                        danger: true
                        text: root.armedAction === "poweroff" ? "Confirm shutdown?" : "Shutdown"

                        onClicked: root.arm("poweroff")
                    }
                }
                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
