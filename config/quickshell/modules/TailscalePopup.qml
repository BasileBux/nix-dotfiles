import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls as Ctl
import "../services" as Services
import "../widgets" as Widgets
import ".."

Item {
    id: root
    anchors.fill: parent

    required property bool popupShown

    property string feedback: ""
    property bool feedbackIsError: false
    // file:// urls queued for sending, via picker or drag-and-drop
	property var pendingFiles: []
	readonly property bool pickersOpen: sendDialog.visible || saveDialog.visible

    function showFeedback(text, isError) {
        feedback = text;
        feedbackIsError = isError === true;
    }

    function urlToPath(url) {
        return decodeURIComponent(String(url).replace(/^file:\/\//, ""));
    }

    onPendingFilesChanged: showFeedback("", false)

    onPopupShownChanged: {
        Services.Tailscale.panelVisible = popupShown;
        if (popupShown) Services.Tailscale.refresh();
    }

    FileDialog {
        id: sendDialog
        fileMode: FileDialog.OpenFiles
        onAccepted: root.pendingFiles = selectedFiles
    }

    FolderDialog {
        id: saveDialog
        currentFolder: "file://" + Services.Tailscale.downloadDir
        onAccepted: {
            Globals.playSound(Globals.sounds.click);
            Services.Tailscale.receiveFiles(root.urlToPath(selectedFolder), output => {
                root.showFeedback(output.length > 0 ? output : "Inbox empty", false);
            });
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Globals.spacing

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Widgets.Switch {
                id: enabledToggle
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                widgetWidth: 50
                widgetHeight: 25
                enabled: !Services.Tailscale.busy
                toggleFunction: Services.Tailscale.toggle
                toggleState: Services.Tailscale.running
            }

            Text {
                anchors {
                    left: enabledToggle.right
                    leftMargin: Globals.spacing
                    verticalCenter: parent.verticalCenter
                }
                color: Globals.theme.foreground
                font.pixelSize: Globals.fonts.medium
                font.family: Globals.theme.fontFamily
                text: {
                    if (Services.Tailscale.busy) return "Working…";
                    if (Services.Tailscale.backendState === "NeedsLogin") return "Needs login";
                    return Services.Tailscale.running ? "Tailscale On" : "Tailscale Off";
                }
            }

            Widgets.TintIcon {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                visible: Services.Tailscale.backendState === "NeedsLogin" && Services.Tailscale.authUrl !== ""
                source: "../icons/warning.svg"
                width: Globals.fonts.xlarge
                height: Globals.fonts.xlarge
                color: Globals.colors.red

                MouseArea {
                    anchors.fill: parent
                    onClicked: Quickshell.execDetached([Globals.browser, Services.Tailscale.authUrl])
                }
            }
        }

        Text {
            Layout.fillWidth: true
            color: Services.Tailscale.running ? Globals.theme.accent1 : Globals.theme.muted
            font.pixelSize: Globals.fonts.small
            font.family: Globals.theme.fontFamily
            elide: Text.ElideRight
            text: {
                if (!Services.Tailscale.running)
                    return Services.Tailscale.backendState === "NeedsLogin" ? "Login required" : "Tailscale is disabled";
                if (Services.Tailscale.currentExitNode !== "")
                    return "Exit node: " + Services.Tailscale.currentExitNode;
                return "Direct connection (no exit node)";
            }
        }

        Text {
            Layout.fillWidth: true
            color: Globals.theme.muted
            font.pixelSize: Globals.fonts.xsmall
            font.family: Globals.theme.fontFamily
            text: "EXIT NODES"
        }

        ListView {
            id: exitNodeList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 160)
            spacing: 2
            clip: true
            model: [{ none: true }].concat(Services.Tailscale.exitNodes)

            delegate: Item {
                id: delegateItem
                width: exitNodeList.width
                height: 26
                readonly property bool isNone: modelData.none === true
                readonly property bool isCurrent: isNone
                    ? Services.Tailscale.currentExitNode === ""
                    : Services.Tailscale.currentExitNode === modelData.name

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: ma.containsMouse ? Globals.theme.muted : "transparent"
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!delegateItem.isCurrent)
                            Services.Tailscale.setExitNode(delegateItem.isNone ? null : modelData);
                    }
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Globals.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    color: {
                        if (delegateItem.isCurrent) return Globals.theme.accent1;
                        if (!delegateItem.isNone && !modelData.online) return Globals.theme.muted;
                        return Globals.theme.foreground;
                    }
                    font.pixelSize: Globals.fonts.small
                    font.family: Globals.theme.fontFamily
                    font.bold: delegateItem.isCurrent
                    elide: Text.ElideRight
                    width: parent.width - 140
                    text: delegateItem.isNone ? "None (direct)" : modelData.name
                }
                Text {
                    anchors {
                        right: statusDot.left
                        rightMargin: Globals.spacing
                        verticalCenter: parent.verticalCenter
                    }
                    visible: !delegateItem.isNone
                    color: Globals.theme.muted
                    font.pixelSize: Globals.fonts.xsmall
                    font.family: Globals.theme.fontFamily
                    elide: Text.ElideRight
                    text: delegateItem.isNone ? "" : modelData.location
                }
                Text {
                    id: statusDot
                    anchors {
                        right: parent.right
                        rightMargin: Globals.spacing * 2
                        verticalCenter: parent.verticalCenter
                    }
                    visible: !delegateItem.isNone
                    color: delegateItem.isNone ? "transparent" : (modelData.online ? Globals.colors.brightGreen : Globals.theme.muted)
                    font.pixelSize: Globals.fonts.xsmall
                    text: "●"
                }
            }
        }

        Text {
            Layout.fillWidth: true
            color: Globals.theme.muted
            font.pixelSize: Globals.fonts.xsmall
            font.family: Globals.theme.fontFamily
            text: "TAILDROP"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Globals.spacing

            Widgets.PillButton {
                text: "Browse…"
                enabled: !Services.Tailscale.busy
                onClicked: sendDialog.open()
            }

            Text {
                Layout.fillWidth: true
                color: root.pendingFiles.length > 0 ? Globals.theme.foreground : Globals.theme.muted
                font.pixelSize: Globals.fonts.small
                font.family: Globals.theme.fontFamily
                elide: Text.ElideMiddle
                text: {
                    if (root.pendingFiles.length === 0)
                        return "No files selected (or drop them here)";
                    if (root.pendingFiles.length === 1)
                        return root.urlToPath(root.pendingFiles[0]);
                    return root.pendingFiles.length + " files selected";
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Globals.spacing

            ComboBox {
                id: sendTarget
                Layout.fillWidth: true
                model: Services.Tailscale.fileTargets.map(t => t.name)
                font.pixelSize: Globals.fonts.small
                enabled: model.length > 0

                background: Rectangle {
                    radius: 6
                    color: sendTarget.enabled ? Globals.theme.muted : Globals.theme.background
                    border.color: Globals.theme.border
                }
                contentItem: Text {
                    leftPadding: 8
                    rightPadding: 20
                    verticalAlignment: Text.AlignVCenter
                    text: sendTarget.displayText
                    color: Globals.theme.foreground
                    font.pixelSize: Globals.fonts.small
                    font.family: Globals.theme.fontFamily
                    elide: Text.ElideRight
                }
                indicator: Text {
                    x: sendTarget.width - width - 8
                    y: sendTarget.height / 2 - height / 2
                    text: "▾"
                    color: Globals.theme.muted
                }
                delegate: ItemDelegate {
                    id: targetDelegate
                    width: sendTarget.width
                    height: 26
                    highlighted: sendTarget.highlightedIndex === index

                    background: Rectangle {
                        radius: 6
                        color: targetDelegate.highlighted ? Globals.theme.accent2 : "transparent"
                    }
                    contentItem: Text {
                        leftPadding: 8
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        color: Globals.theme.foreground
                        font.pixelSize: Globals.fonts.small
                        font.family: Globals.theme.fontFamily
                        elide: Text.ElideRight
                    }
                }
                popup: Ctl.Popup {
                    y: sendTarget.height + 2
                    width: sendTarget.width
                    padding: 2
                    background: Rectangle {
                        radius: 6
                        color: Globals.theme.background
                        border.color: Globals.theme.border
                    }
                    ListView {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        clip: true
                        implicitHeight: Math.min(contentHeight, 140)
                        model: sendTarget.popup.visible ? sendTarget.delegateModel : null
                        currentIndex: sendTarget.highlightedIndex
                    }
                }
            }

            Widgets.PillButton {
                text: "Send"
                highlighted: true
                enabled: !Services.Tailscale.busy && root.pendingFiles.length > 0 && sendTarget.model.length > 0
                onClicked: {
                    Globals.playSound(Globals.sounds.click);
                    Services.Tailscale.sendFiles(root.pendingFiles.map(root.urlToPath), sendTarget.displayText, output => {
                        root.showFeedback(output.length > 0 ? output : "Sent to " + sendTarget.displayText, false);
                        root.pendingFiles = [];
                    });
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Globals.spacing

            Widgets.PillButton {
                text: "Receive files…"
                enabled: !Services.Tailscale.busy
                onClicked: saveDialog.open()
            }

            Text {
                color: Globals.theme.muted
                font.pixelSize: Globals.fonts.xsmall
                font.family: Globals.theme.fontFamily
                text: "default: ~/Downloads"
            }
        }

        Text {
            Layout.fillWidth: true
            visible: root.feedback.length > 0
            color: root.feedbackIsError ? Globals.colors.red : Globals.theme.muted
            font.pixelSize: Globals.fonts.xsmall
            font.family: Globals.theme.fontFamily
            wrapMode: Text.WrapAnywhere
            maximumLineCount: 4
            elide: Text.ElideRight
            text: root.feedback
        }

        Item {
            Layout.fillHeight: true
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        onDropped: drop => {
            if (drop.hasUrls) {
                root.pendingFiles = drop.urls;
                Globals.playSound(Globals.sounds.fancySelect);
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Globals.theme.accent1
        opacity: dropArea.containsDrag ? 0.15 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    Text {
        anchors.centerIn: parent
        visible: dropArea.containsDrag
        color: Globals.theme.foreground
        font.pixelSize: Globals.fonts.large
        font.family: Globals.theme.fontFamily
        font.bold: true
        text: "Drop files here to send"
    }
}
