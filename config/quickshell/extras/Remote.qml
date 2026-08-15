import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import ".."

// On `SUPER + R` opens a dialog where you enter the user@address and optionally
// a TMUX session name and it opens a kitty window with the correct config which
// connected to the remote (through `mosh`) and inside of a named TMUX session

Window {
    id: root
    width: Globals.extras.remoteWidth
    height: Globals.extras.remoteHeight

    maximumWidth: width
    maximumHeight: height
    minimumWidth: width
    minimumHeight: height

    // Best-effort centering on the primary screen.
    // On Hyprland you'll also want a window rule:
    //   windowrulev2 = center, class:^(quickshell)$, title:^(Remote ssh)$
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    flags: Qt.Dialog | Qt.FramelessWindowHint
    color: Globals.theme.background
    title: "Remote ssh"

    visible: false

    function exit() {
        addressField.text = "";
        sessionName.text = "";
        addressField.focus = true;
        sessionName.focus = false;
        root.visible = false;
    }

    function exec() {
        var address = addressField.text.trim();
        var session = sessionName.text;

        if (address.length <= 0) {
            return;
        }

        if (session.length <= 0) {
            session = Globals.extras.remoteDefaultTmuxSession;
        }

        // Parse optional port: "root@example.com 2222" -> address="root@example.com", port=2222
        var port = 22;
        var parts = address.split(" ");
        if (parts.length > 1) {
            var lastPart = parts[parts.length - 1];
            if (/^[0-9]+$/.test(lastPart)) {
                port = parseInt(lastPart);
                address = parts.slice(0, -1).join(" ");
            }
        }

        var user = Quickshell.env("USER");

        Quickshell.execDetached({
            command: ["kitty", "--config", `/home/${user}/.config/kitty/remote.conf`, "mosh", "--ssh=ssh -p " + port, address, "--", "tmux", "new-session", "-A", "-s", session]
        });

        exit();
    }

    readonly property int widthRatio: 25

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Globals.spacing * 2
        spacing: Globals.spacing

        Text {
            id: titleText
            Layout.alignment: Qt.AlignHCenter
            text: "Remote ssh"
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.xlarge
            font.bold: true
        }

        Text {
            id: addressDescText
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: parent.width * 1 / (2 * root.widthRatio)
            text: "user@host [port]:"
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.small
            font.bold: true
        }
        TextField {
            id: addressField
            implicitWidth: parent.width * (root.widthRatio - 1) / root.widthRatio
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            visible: true
            enabled: true
            focus: true

            echoMode: TextField.Normal
            placeholderText: ""
            inputMethodHints: Qt.ImhSensitiveData
            horizontalAlignment: TextInput.AlignHCenter
            font.pixelSize: Globals.fonts.medium
            color: Globals.theme.foreground

            // Submit on Enter
            onAccepted: {
                addressField.focus = false;
                sessionName.focus = true;
            }

            // Cancel on Escape
            Keys.onEscapePressed: {
                root.exit();
            }

            background: Rectangle {
                color: Globals.theme.muted
                border.color: Globals.theme.accent2
                border.width: 1
                radius: Globals.radius
            }
        }

        Text {
            id: sessionDescText
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: parent.width * 1 / (root.widthRatio * 2)
            text: "Tmux session name:"
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.small
            font.bold: true
        }
        TextField {
            id: sessionName
            implicitWidth: parent.width * (root.widthRatio - 1) / root.widthRatio
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            visible: true
            enabled: true
            focus: false

            echoMode: TextField.Normal
            placeholderText: ""
            inputMethodHints: Qt.ImhSensitiveData
            horizontalAlignment: TextInput.AlignHCenter
            font.pixelSize: Globals.fonts.medium
            color: Globals.theme.foreground

            // Submit on Enter
            onAccepted: {
                root.exec();
            }

            // Cancel on Escape
            Keys.onEscapePressed: {
                root.exit();
            }

            background: Rectangle {
                color: Globals.theme.muted
                border.color: Globals.theme.accent2
                border.width: 1
                radius: Globals.radius
            }
        }

        Button {
            id: enterButton
            text: "Enter"
            implicitWidth: parent.width * (root.widthRatio - 1) / root.widthRatio
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            visible: true
            enabled: true

            onClicked: {
                root.exec();
            }

            contentItem: Text {
                text: enterButton.text
                color: Globals.theme.foreground
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.small
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: enterButton.hovered ? Globals.theme.muted : Globals.theme.background
                border.color: Globals.theme.accent2
                border.width: 1
                radius: Globals.radius
            }
        }
    }

    GlobalShortcut {
        name: "remote"
        onPressed: {
            if (root.visible) {
                root.exit();
            } else {
                root.visible = true;
            }
        }
    }
}
