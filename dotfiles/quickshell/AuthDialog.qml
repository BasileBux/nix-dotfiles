import QtQuick
import QtQuick.Controls
import Quickshell.Services.Polkit

Window {
    id: root

    required property PolkitAgent agent
    readonly property var flow: root.agent ? root.agent.flow : null

	readonly property int buttonWidth: 110
	readonly property int buttonHeight: 32

    width: Globals.authDialogWidth
    height: Globals.authDialogHeight
    maximumWidth: width
    maximumHeight: height
    minimumWidth: width
    minimumHeight: height

    // Best-effort centering on the primary screen.
    // On Hyprland you'll also want a window rule:
    //   windowrulev2 = center, class:^(quickshell)$, title:^(Authentication Required)$
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    flags: Qt.Dialog | Qt.FramelessWindowHint
    color: Globals.theme.background
    title: "Authentication Required"

    // Only show when there's an active flow
    visible: root.agent && root.agent.isActive

    Column {
        anchors.fill: parent
        anchors.margins: Globals.spacing * 2
        spacing: Globals.spacing

        // ── Title ──
        Text {
            id: titleText
            text: "Authentication Required"
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.xlarge
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // ── Action message ──
        Text {
            id: messageText
            text: root.flow ? root.flow.message : ""
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.small
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            maximumLineCount: 4
            elide: Text.ElideRight
        }

        // ── Supplementary message (error / info) ──
        Text {
            id: supplementaryText
            text: (root.flow && root.flow.supplementaryMessage) ? root.flow.supplementaryMessage : ""
            color: (root.flow && root.flow.supplementaryIsError) ? Globals.theme.accent1 : Globals.theme.muted
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.xsmall
            font.italic: !(root.flow && root.flow.supplementaryIsError)
            visible: root.flow && root.flow.supplementaryMessage !== ""
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        Item {
            height: 2
            width: 1
        }

        // ── Password input ──
        TextField {
            id: passwordField
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 9 / 10
            implicitHeight: parent.height / 5
            visible: root.flow && root.flow.isResponseRequired
            enabled: root.flow && !root.flow.isCompleted

            echoMode: (root.flow && root.flow.responseVisible) ? TextField.Normal : TextField.Password
            placeholderText: root.flow ? root.flow.inputPrompt : ""
            inputMethodHints: Qt.ImhSensitiveData
            horizontalAlignment: TextInput.AlignHCenter
            font.pixelSize: Globals.fonts.medium
            color: Globals.theme.foreground

            // Submit on Enter
            onAccepted: {
                if (root.flow && root.flow.isResponseRequired && !root.flow.isCompleted) {
                    root.flow.submit(passwordField.text);
                    passwordField.text = "";
                }
            }

            // Cancel on Escape
            Keys.onEscapePressed: {
                if (root.flow && !root.flow.isCompleted) {
                    root.flow.cancelAuthenticationRequest();
                }
            }

            background: Rectangle {
                color: Globals.theme.muted
                border.color: Globals.theme.accent2
                border.width: 1
                radius: Globals.radius
            }
        }

        Item {
            height: 2
            width: 1
        }

        // ── Buttons ──
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Globals.spacing * 2

            Button {
                id: cancelButton
                text: "Cancel"
                implicitWidth: root.buttonWidth
                implicitHeight: root.buttonHeight
                visible: root.flow && !root.flow.isCompleted
                enabled: root.flow && !root.flow.isCompleted

                onClicked: {
                    if (root.flow) {
                        root.flow.cancelAuthenticationRequest();
                    }
                }

                contentItem: Text {
                    text: cancelButton.text
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.small
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: cancelButton.hovered ? Globals.theme.muted : Globals.theme.background
                    border.color: Globals.theme.border
                    border.width: 1
                    radius: Globals.radius
                }
            }

            Button {
                id: submitButton
                text: "Authenticate"
                implicitWidth: root.buttonWidth
                implicitHeight: root.buttonHeight
                visible: root.flow && root.flow.isResponseRequired
                enabled: root.flow && root.flow.isResponseRequired && !root.flow.isCompleted

                onClicked: {
                    if (root.flow) {
                        root.flow.submit(passwordField.text);
                        passwordField.text = "";
                    }
                }

                contentItem: Text {
                    text: submitButton.text
                    color: Globals.theme.background
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.small
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: submitButton.hovered ? Globals.theme.accent3 : Globals.theme.accent1
                    border.color: Globals.theme.accent2
                    border.width: 1
                    radius: Globals.radius
                }
            }
        }
    }

    // Cancel auth if the window is closed externally
    onClosing: {
        if (root.flow && !root.flow.isCompleted) {
            root.flow.cancelAuthenticationRequest();
        }
    }

    // ── Completion handling ──
    Connections {
        target: root.flow

        function onAuthenticationSucceeded() {
            root.visible = false;
        }

        function onAuthenticationFailed() {
            passwordField.text = "";
        }

        function onAuthenticationRequestCancelled() {
            root.visible = false;
        }

        function onIsResponseRequiredChanged() {
            if (root.flow && root.flow.isResponseRequired) {
                passwordField.forceActiveFocus();
            }
        }
    }
}
