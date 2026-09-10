import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Controls as Ctl
import QtQuick.Dialogs
import QtQuick.Layouts
import "../../services" as Services
import "../widgets" as PWidgets
import "../../widgets" as Widgets
import "../.."

Item {
    id: root

    property string feedback: ""
    property bool feedbackIsError: false
    // file:// urls queued for sending, via picker or drag-and-drop
    property var pendingFiles: []
    readonly property bool pickersOpen: sendDialog.visible || saveDialog.visible
    readonly property bool popupShown: PaletteState.viewId === "tailscale"

    function showFeedback(text, isError) {
        feedback = text;
        feedbackIsError = isError === true;
    }
    function urlToPath(url) {
        return decodeURIComponent(String(url).replace(/^file:\/\//, ""));
    }
    function stateText() {
        if (Services.Tailscale.busy)
            return "Working…";
        if (Services.Tailscale.backendState === "NeedsLogin")
            return "Login required";
        if (!Services.Tailscale.running)
            return "Disabled";
        if (Services.Tailscale.currentExitNode !== "")
            return "Connected · exit node " + Services.Tailscale.currentExitNode;
        return "Connected · direct";
    }

    onPendingFilesChanged: showFeedback("", false)
    onPopupShownChanged: {
        Services.Tailscale.panelVisible = popupShown;
        if (popupShown)
            Services.Tailscale.refresh();
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

    Item {
        anchors.fill: parent
        anchors.margins: Globals.space2

        Flickable {
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            contentHeight: content.height
            contentWidth: width

            ColumnLayout {
                id: content

                spacing: Globals.space2
                width: parent.width

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    spacing: Globals.space2

                    Widgets.Switch {
                        id: enabledToggle

                        enabled: !Services.Tailscale.busy
                        toggleFunction: Services.Tailscale.toggle
                        toggleState: Services.Tailscale.running
                    }
                    Text {
                        color: Globals.theme.foreground
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.body
                        text: "Tailscale"
                    }
                    Rectangle {
                        color: Services.Tailscale.running ? Globals.colors.success : Globals.theme.muted
                        height: 7
                        radius: 3.5
                        visible: Services.Tailscale.running
                        width: 7
                    }
                    Text {
                        Layout.fillWidth: true
                        color: Services.Tailscale.backendState === "NeedsLogin" ? Globals.colors.warning : Globals.theme.foreground
                        elide: Text.ElideRight
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.caption
                        text: root.stateText()
                    }
                    PWidgets.IconButton {
                        danger: true
                        icon: "warning"
                        visible: Services.Tailscale.backendState === "NeedsLogin" && Services.Tailscale.authUrl !== ""

                        onClicked: Quickshell.execDetached([Globals.browser, Services.Tailscale.authUrl])
                    }
                }

                PWidgets.SectionLabel {
                    Layout.topMargin: Globals.space2
                    label: "Exit nodes"
                }
                ListView {
                    id: exitNodeList

                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 180)
                    clip: true
                    model: [
                        {
                            none: true
                        }
                    ].concat(Services.Tailscale.exitNodes)
                    spacing: Globals.space1

                    delegate: PWidgets.Row {
                        id: nodeRow

                        readonly property bool isCurrent: nodeRow.isNone ? Services.Tailscale.currentExitNode === "" : Services.Tailscale.currentExitNode === modelData.name
                        readonly property bool isNone: modelData.none === true

                        height: 40
                        selected: nodeRow.isCurrent
                        title: nodeRow.isNone ? "None (direct)" : modelData.name

                        onClicked: {
                            if (!nodeRow.isCurrent)
                                Services.Tailscale.setExitNode(nodeRow.isNone ? null : modelData);
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            color: Globals.theme.muted
                            elide: Text.ElideRight
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.micro
                            text: nodeRow.isNone ? "" : modelData.location
                            visible: !nodeRow.isNone
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            color: modelData.online ? Globals.colors.success : Globals.theme.muted
                            height: 7
                            radius: 3.5
                            visible: !nodeRow.isNone
                            width: 7
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                }
                PWidgets.EmptyState {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: Globals.space2
                    caption: "This tailnet has only direct peers"
                    icon: "tailscale"
                    title: "No exit nodes"
                    visible: Services.Tailscale.exitNodes.length === 0
                }

                // Taildrop
                PWidgets.SectionLabel {
                    Layout.topMargin: Globals.space2
                    label: "Taildrop"
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Globals.space2

                    Widgets.PillButton {
                        enabled: !Services.Tailscale.busy
                        text: "Browse…"

                        onClicked: sendDialog.open()
                    }
                    Text {
                        Layout.fillWidth: true
                        color: root.pendingFiles.length > 0 ? Globals.theme.foreground : Globals.theme.muted
                        elide: Text.ElideMiddle
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.caption
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
                    spacing: Globals.space2

                    ComboBox {
                        id: sendTarget

                        Layout.preferredWidth: 280
                        enabled: count > 0
                        opacity: enabled ? 1 : 0.55
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.body
                        implicitHeight: 36
                        leftPadding: Globals.margin
                        rightPadding: Globals.space4 + Globals.space2
                        model: Services.Tailscale.fileTargets.map(t => t.name)

                        background: Rectangle {
                            border.color: sendTarget.activeFocus || sendTarget.popup.visible ? Globals.accent : Globals.controlBorder
                            border.width: 1
                            color: sendTarget.hovered ? Globals.tone4 : Globals.tone3
                            radius: Globals.radius
                        }
                        contentItem: Text {
                            color: Globals.theme.foreground
                            elide: Text.ElideRight
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.body
                            text: sendTarget.count > 0 ? sendTarget.displayText : "No devices available"
                            verticalAlignment: Text.AlignVCenter
                        }
                        delegate: ItemDelegate {
                            id: targetDelegate
                            height: 36
                            highlighted: sendTarget.highlightedIndex === index
                            width: sendTarget.width - Globals.space2
                            leftPadding: Globals.margin
                            rightPadding: Globals.margin
                            background: Rectangle {
                                color: targetDelegate.highlighted ? Globals.accentFill : "transparent"
                                radius: Globals.radius
                            }
                            contentItem: Text {
                                color: Globals.theme.foreground
                                elide: Text.ElideRight
                                font.family: Globals.theme.fontFamily
                                font.pixelSize: Globals.fonts.body
                                text: modelData
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        indicator: Text {
                            color: Globals.theme.foreground
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.body
                            text: "▾"
                            x: sendTarget.width - width - Globals.margin
                            y: sendTarget.height / 2 - height / 2
                        }
                        popup: Ctl.Popup {
                            padding: Globals.space1
                            width: sendTarget.width
                            y: sendTarget.height + Globals.space1
                            implicitHeight: Math.min(targetList.contentHeight, 180) + padding * 2
                            background: Rectangle {
                                color: Globals.tone2
                                border.width: 1
                                border.color: Globals.controlBorder
                                radius: Globals.radius
                            }
                            contentItem: ListView {
                                id: targetList
                                clip: true
                                currentIndex: sendTarget.highlightedIndex
                                model: sendTarget.popup.visible ? sendTarget.delegateModel : null
                                boundsBehavior: Flickable.StopAtBounds
                                ScrollIndicator.vertical: ScrollIndicator {}
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Widgets.PillButton {
                        Layout.preferredWidth: 110
                        enabled: !Services.Tailscale.busy && root.pendingFiles.length > 0 && sendTarget.model.length > 0
                        highlighted: true
                        text: "Send"

                        onClicked: {
                            Globals.playSound(Globals.sounds.click);
                            Services.Tailscale.sendFiles(root.pendingFiles.map(root.urlToPath), sendTarget.displayText, output => {
                                root.showFeedback(output.length > 0 ? output : "Sent to " + sendTarget.displayText, false);
                                root.pendingFiles = [];
                            });
                        }
                    }
                    Widgets.PillButton {
                        enabled: !Services.Tailscale.busy
                        text: "Receive files…"

                        onClicked: saveDialog.open()
                    }
                }
                Text {
                    Layout.fillWidth: true
                    color: root.feedbackIsError ? Globals.colors.dangerText : Globals.theme.muted
                    elide: Text.ElideRight
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    maximumLineCount: 4
                    text: root.feedback
                    visible: root.feedback.length > 0
                    wrapMode: Text.WrapAnywhere
                }
                Item {
                    Layout.fillHeight: true
                }
            }
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
    // Drop target: the ramp-based tone2 overlay, so it never reads as another
    // glass card. Appears and disappears in one frame.
    PWidgets.Surface {
        anchors.fill: parent
        fill: Globals.tone2
        flush: true
        level: 2
        strokeColor: Globals.accent
        strokeWidth: 2
        visible: dropArea.containsDrag

        Text {
            anchors.centerIn: parent
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.title
            font.weight: Font.DemiBold
            text: "Drop files here to send"
        }
    }
}
