import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import ".."

// Session manager for the Kamina remote. The normal remote shortcut opens a
// plain SSH shell directly; this menu is for choosing between a plain shell
// and persistent tmux sessions.

Window {
    id: root
    width: Globals.extras.remoteWidth
    height: Globals.extras.remoteHeight

    maximumWidth: width
    maximumHeight: height
    minimumWidth: width
    minimumHeight: height

    flags: Qt.Dialog | Qt.FramelessWindowHint
    color: Globals.theme.background
    title: "Remote ssh"

    visible: false

    property string hostname: "kamina"
    property string viewState: "hidden"
    property string errorMessage: ""
    property string actionError: ""
    property int pickerIndex: 0

    readonly property string remoteTmuxConfig: Quickshell.env("HOME") + "/.config/kitty/remote.conf"

    ListModel {
        id: sessionsModel
    }

    function open() {
        sessionsProcess.running = false;
        connectivityProcess.running = false;

        root.visible = true;
        root.viewState = "loading";
        root.errorMessage = "";
        root.pickerIndex = 0;
        root.actionError = "";
        sessionsModel.clear();
        sessionNameField.text = "";
        keyHandler.forceActiveFocus();

        connectivityProcess.running = true;
    }

    function close() {
        root.visible = false;
        root.viewState = "hidden";
        connectivityProcess.running = false;
        sessionsProcess.running = false;
    }

    function showError(message) {
        root.errorMessage = message;
        root.viewState = "error";
    }

    function populateSessions(output) {
        sessionsModel.clear();

        var names = output.split(/\r?\n/).map(function (line) {
            return line.trim();
        }).filter(function (line) {
            return line.length > 0;
        });
        names.sort();

        for (var i = 0; i < names.length; i++)
            sessionsModel.append({ name: names[i] });
    }

    // SSH concatenates the arguments after the host into a remote shell
    // command. Quote session names before putting them into that command.
    function shellQuote(value) {
        return "'" + value.replace(/'/g, "'\\''") + "'";
    }

    function pickerOptionCount() {
        // Plain shell, one entry per tmux session, and the new-session entry.
        return sessionsModel.count + 2;
    }

    function movePicker(delta) {
        root.pickerIndex = Math.max(0, Math.min(
            root.pickerIndex + delta,
            root.pickerOptionCount() - 1
        ));
    }

    function activatePickerOption() {
        if (root.pickerIndex === 0) {
            root.launchPlain();
            return;
        }

        if (root.pickerIndex <= sessionsModel.count) {
            root.launchTmux(sessionsModel.get(root.pickerIndex - 1).name, false);
            return;
        }

        // Focus the name field first so Enter -> type -> Enter is enough to
        // create a named session. An empty field still uses the default name.
        sessionNameField.forceActiveFocus();
    }

    function launchPlain() {
        Quickshell.execDetached({
            command: ["kitty", "kitten", "ssh", root.hostname]
        });
        close();
    }

    function launchTmux(session, create) {
        var action = create ? "tmux new-session -A -s " : "tmux attach-session -t ";
        var remoteCommand = action + shellQuote(session);

        Quickshell.execDetached({
            command: [
                "kitty",
                "--config",
                root.remoteTmuxConfig,
                "ssh",
                "-t",
                root.hostname,
                remoteCommand
            ]
        });
        close();
    }

    function createSession() {
        var session = sessionNameField.text.trim();
        if (session.length === 0)
            session = Globals.extras.remoteDefaultTmuxSession;

        if (/[\r\n]/.test(session)) {
            root.actionError = "Session names cannot contain newlines.";
            return;
        }

        launchTmux(session, true);
    }

    Process {
        id: connectivityProcess
        command: [
            "ssh",
            "-o", "BatchMode=yes",
            "-o", "ConnectTimeout=4",
            "-o", "ConnectionAttempts=1",
            root.hostname,
            "true"
        ]
        running: false

        stderr: StdioCollector {
            id: connectivityStderr
        }

        onExited: function(exitCode, exitStatus) {
            if (!root.visible)
                return;

            if (exitCode !== 0) {
                var details = connectivityStderr.text.trim();
                root.showError(details.length > 0
                    ? root.hostname + " is unreachable.\n" + details
                    : root.hostname + " is unreachable.");
                return;
            }

            sessionsProcess.running = true;
        }
    }

    Process {
        id: sessionsProcess
        command: [
            "ssh",
            "-o", "BatchMode=yes",
            "-o", "ConnectTimeout=4",
            "-o", "ConnectionAttempts=1",
            root.hostname,
            "tmux list-sessions -F '#{session_name}'"
        ]
        running: false

        stdout: StdioCollector {
            id: sessionsStdout
        }

        stderr: StdioCollector {
            id: sessionsStderr
        }

        onExited: function(exitCode, exitStatus) {
            if (!root.visible)
                return;

            var details = sessionsStderr.text.trim();
            var noTmuxServer = /no server running/i.test(details)
                || (/error connecting to .*tmux.*no such file or directory/i.test(details));

            // tmux exits non-zero when no server exists. That is a normal
            // empty-session state, not a connectivity failure.
            if (exitCode !== 0 && !noTmuxServer) {
                root.showError(details.length > 0
                    ? "Could not list " + root.hostname + "'s tmux sessions.\n" + details
                    : "Could not list " + root.hostname + "'s tmux sessions.");
                return;
            }

            root.populateSessions(sessionsStdout.text);
            root.viewState = "picker";
        }
    }

    Item {
        id: keyHandler
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.close();
                event.accepted = true;
                return;
            }

            if (root.viewState !== "picker")
                return;

            if (event.key === Qt.Key_Up) {
                root.movePicker(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                root.movePicker(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.activatePickerOption();
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Globals.spacing * 2
        spacing: Globals.spacing

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.hostname + " sessions"
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.xlarge
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            visible: root.viewState === "loading"
            text: "Checking whether " + root.hostname + " is reachable…"
            color: Globals.theme.muted
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.small
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.viewState === "error"
            spacing: Globals.spacing

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.errorMessage
                color: Globals.colors.red
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.small
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    Layout.fillWidth: true
                    text: "Retry"
                    onClicked: root.open()

                    contentItem: Text {
                        text: parent.text
                        color: Globals.theme.foreground
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.small
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.hovered ? Globals.theme.muted : Globals.theme.background
                        border.color: Globals.theme.accent2
                        border.width: 1
                        radius: Globals.radius
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Close"
                    onClicked: root.close()

                    contentItem: Text {
                        text: parent.text
                        color: Globals.theme.foreground
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.small
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.hovered ? Globals.theme.muted : Globals.theme.background
                        border.color: Globals.theme.accent2
                        border.width: 1
                        radius: Globals.radius
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.viewState === "picker"
            spacing: Globals.spacing

            Button {
                Layout.fillWidth: true
                implicitHeight: 36
                text: "Plain SSH shell"
                onClicked: root.launchPlain()

                contentItem: Text {
                    text: parent.text
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: (parent.hovered || root.pickerIndex === 0)
                        ? Globals.theme.muted : Globals.theme.background
                    border.color: Globals.theme.accent2
                    border.width: 1
                    radius: Globals.radius
                }
            }

            Text {
                Layout.fillWidth: true
                text: sessionsModel.count > 0 ? "Attach to a tmux session:" : "No tmux sessions currently exist."
                color: Globals.theme.muted
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.small
            }

            ListView {
                id: sessionList
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: sessionsModel.count > 0
                clip: true
                spacing: Globals.padding
                model: sessionsModel

                delegate: Rectangle {
                    width: sessionList.width
                    height: 34
                    color: (sessionMouse.containsMouse || root.pickerIndex === index + 1)
                        ? Globals.theme.muted : "transparent"
                    radius: Globals.radius

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: Globals.spacing
                        anchors.rightMargin: Globals.spacing
                        text: model.name
                        color: Globals.theme.foreground
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.medium
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: sessionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.launchTmux(model.name, false)
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.actionError.length > 0
                text: root.actionError
                color: Globals.colors.red
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.xsmall
                wrapMode: Text.Wrap
            }

            RowLayout {
                Layout.fillWidth: true

                TextField {
                    id: sessionNameField
                    Layout.fillWidth: true
                    implicitHeight: 34
                    placeholderText: "New session name (default: " + Globals.extras.remoteDefaultTmuxSession + ")"
                    placeholderTextColor: Globals.theme.muted
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.small
                    onTextChanged: root.actionError = ""
                    onAccepted: root.createSession()

                    background: Rectangle {
                        color: Globals.theme.muted
                        border.color: Globals.theme.accent2
                        border.width: 1
                        radius: Globals.radius
                    }
                }

                Button {
                    implicitWidth: 110
                    implicitHeight: 34
                    text: "New tmux"
                    onClicked: root.createSession()

                    contentItem: Text {
                        text: parent.text
                        color: Globals.theme.foreground
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.small
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: (parent.hovered || root.pickerIndex === sessionsModel.count + 1)
                            ? Globals.theme.muted : Globals.theme.background
                        border.color: Globals.theme.accent2
                        border.width: 1
                        radius: Globals.radius
                    }
                }
            }
        }
    }

    GlobalShortcut {
        name: "remote"
        onPressed: {
            if (root.visible)
                root.close();
            else
                root.open();
        }
    }
}
