import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import ".."

Rectangle {
    id: root

    required property LockContext context

    color: Globals.theme.background

    // Test button
    // Button {
    // 	text: "Its not working, let me out"
    // 	onClicked: context.unlocked();
    // }

    Image {
        id: backgroundImage

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: 0.3
        source: "../" + Globals.theme.wallpaper
    }
    Label {
        id: clock

        property var date: new Date()

        color: Globals.theme.foreground
        font.family: Globals.theme.fontFamily
        font.pointSize: 80
        renderType: Text.NativeRendering
        text: {
            const hours = this.date.getHours().toString().padStart(2, '0');
            const minutes = this.date.getMinutes().toString().padStart(2, '0');
            const seconds = this.date.getSeconds().toString().padStart(2, '0');
            return `${hours}:${minutes}:${seconds}`;
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.verticalCenter
            topMargin: Globals.margin * -5
        }
        Timer {
            interval: 1000
            repeat: true
            running: true

            onTriggered: clock.date = new Date()
        }
    }
    ColumnLayout {
        // Make the password entry invisible except on the active monitor.
        visible: Window.active

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.verticalCenter
            topMargin: Globals.margin * 5
        }
        RowLayout {
            TextField {
                id: passwordBox

                color: Globals.theme.foreground
                echoMode: TextInput.Password
                enabled: !root.context.unlockInProgress
                focus: true
                font.pixelSize: Globals.fonts.lead
                horizontalAlignment: TextInput.AlignHCenter
                implicitHeight: 50
                implicitWidth: 300
                inputMethodHints: Qt.ImhSensitiveData
                padding: Globals.space2 + Globals.space1

                background: Rectangle {
                    border.color: "transparent"
                    border.width: 0
                    color: Globals.well
                    radius: Globals.radius
                }

                // Try to unlock when enter is pressed.
                onAccepted: root.context.tryUnlock()

                // Update the text in the context when the text in the box changes.
                onTextChanged: root.context.currentText = this.text

                // Update the text in the box to match the text in the context.
                // This makes sure multiple monitors have the same text.
                Connections {
                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }

                    target: root.context
                }
            }
        }
        Label {
            color: Globals.colors.dangerText
            font.pixelSize: Globals.fonts.body
            text: "Incorrect password"
            visible: root.context.showFailure
        }
    }
}
