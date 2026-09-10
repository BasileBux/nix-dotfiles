import QtQuick
import QtQuick.Controls
import Quickshell.Services.Polkit

Window {
    id: root

    required property PolkitAgent agent
    readonly property int buttonHeight: 32
    readonly property int buttonWidth: 110
    readonly property var flow: root.agent ? root.agent.flow : null

    color: Globals.theme.background
    flags: Qt.Dialog | Qt.FramelessWindowHint
    height: Globals.authDialogHeight
    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width
    title: "Authentication Required"

    // Only show when there's an active flow
    visible: root.agent && root.agent.isActive
    width: Globals.authDialogWidth

    // Best-effort centering on the primary screen.
    // On Hyprland you'll also want a window rule:
    //   windowrulev2 = center, class:^(quickshell)$, title:^(Authentication Required)$
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2

    // Cancel auth if the window is closed externally
    onClosing: {
        if (root.flow && !root.flow.isCompleted) {
            root.flow.cancelAuthenticationRequest();
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Globals.margin
        spacing: Globals.space2

        // ── Title ──
        Text {
            id: titleText

            anchors.horizontalCenter: parent.horizontalCenter
            color: Globals.theme.foreground
            font.bold: true
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.title
            text: "Authentication Required"
        }

        // ── Action message ──
        Text {
            id: messageText

            color: Globals.theme.foreground
            elide: Text.ElideRight
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.caption
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 4
            text: root.flow ? root.flow.message : ""
            width: parent.width
            wrapMode: Text.WordWrap
        }

        // ── Supplementary message (error / info) ──
        Text {
            id: supplementaryText

            color: (root.flow && root.flow.supplementaryIsError) ? Globals.colors.dangerText : Globals.theme.muted
            font.family: Globals.theme.fontFamily
            font.italic: !(root.flow && root.flow.supplementaryIsError)
            font.pixelSize: Globals.fonts.micro
            horizontalAlignment: Text.AlignHCenter
            text: (root.flow && root.flow.supplementaryMessage) ? root.flow.supplementaryMessage : ""
            visible: root.flow && root.flow.supplementaryMessage !== ""
            width: parent.width
            wrapMode: Text.WordWrap
        }
        Item {
            height: 2
            width: 1
        }

        // ── Password input ──
        TextField {
            id: passwordField

            anchors.horizontalCenter: parent.horizontalCenter
            color: Globals.theme.foreground
            echoMode: (root.flow && root.flow.responseVisible) ? TextField.Normal : TextField.Password
            enabled: root.flow && !root.flow.isCompleted
            font.pixelSize: Globals.fonts.body
            horizontalAlignment: TextInput.AlignHCenter
            implicitHeight: parent.height / 5
            inputMethodHints: Qt.ImhSensitiveData
            placeholderText: root.flow ? root.flow.inputPrompt : ""
            visible: root.flow && root.flow.isResponseRequired
            width: parent.width * 9 / 10

            background: Rectangle {
                border.color: passwordField.activeFocus ? Globals.accent : Globals.controlBorder
                border.width: 1
                color: Globals.tone2
                radius: Globals.radius
            }

            // Cancel on Escape
            Keys.onEscapePressed: {
                if (root.flow && !root.flow.isCompleted) {
                    root.flow.cancelAuthenticationRequest();
                }
            }

            // Submit on Enter
            onAccepted: {
                if (root.flow && root.flow.isResponseRequired && !root.flow.isCompleted) {
                    root.flow.submit(passwordField.text);
                    passwordField.text = "";
                }
            }
        }
        Item {
            height: 2
            width: 1
        }

        // ── Buttons ──
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Globals.margin

            Button {
                id: cancelButton

                enabled: root.flow && !root.flow.isCompleted
                implicitHeight: root.buttonHeight
                implicitWidth: root.buttonWidth
                text: "Cancel"
                visible: root.flow && !root.flow.isCompleted

                background: Rectangle {
                    border.color: Globals.theme.border
                    border.width: 1
                    color: cancelButton.hovered ? Globals.surfaceHover : Globals.tone2
                    radius: Globals.radius
                }
                contentItem: Text {
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    horizontalAlignment: Text.AlignHCenter
                    text: cancelButton.text
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (root.flow) {
                        root.flow.cancelAuthenticationRequest();
                    }
                }
            }
            Button {
                id: submitButton

                enabled: root.flow && root.flow.isResponseRequired && !root.flow.isCompleted
                implicitHeight: root.buttonHeight
                implicitWidth: root.buttonWidth
                text: "Authenticate"
                visible: root.flow && root.flow.isResponseRequired

                background: Rectangle {
                    border.color: Globals.accent
                    border.width: 1
                    color: submitButton.hovered ? Qt.lighter(Globals.accent, 1.1) : Globals.accent
                    radius: Globals.radius
                }
                contentItem: Text {
                    color: Globals.accentContent
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    horizontalAlignment: Text.AlignHCenter
                    text: submitButton.text
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (root.flow) {
                        root.flow.submit(passwordField.text);
                        passwordField.text = "";
                    }
                }
            }
        }
    }

    // ── Completion handling ──
    Connections {
        function onAuthenticationFailed() {
            passwordField.text = "";
        }
        function onAuthenticationRequestCancelled() {
            root.visible = false;
        }
        function onAuthenticationSucceeded() {
            root.visible = false;
        }
        function onIsResponseRequiredChanged() {
            if (root.flow && root.flow.isResponseRequired) {
                passwordField.forceActiveFocus();
            }
        }

        target: root.flow
    }
}
