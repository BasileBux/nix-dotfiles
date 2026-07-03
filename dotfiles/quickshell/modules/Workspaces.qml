import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    anchors.fill: parent

    signal workspaceAdded(workspace: HyprlandWorkspace)
    property int workspaceCount: 0

    readonly property color inactiveColor: Globals.theme.foreground
    readonly property color focusedColor: Globals.theme.accent1
    readonly property color activeColor: Globals.theme.accent3
    readonly property color urgentColor: Globals.theme.accent2
    readonly property int dotSize: 8

    ColumnLayout {
        spacing: Globals.workspacesGap
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        Repeater {
            model: 6
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Item {
                id: workspaceItem
                height: root.dotSize
                Layout.fillWidth: true

                required property int index
                property int workspaceIndex: index + 1
                property HyprlandWorkspace workspace: null
                property bool exists: workspace !== null
                property bool active: workspace?.active ?? false
                property bool urgent: workspace?.urgent ?? false

                Connections {
                    target: root

                    function onWorkspaceAdded(workspace: HyprlandWorkspace) {
                        if (workspace.id == workspaceItem.workspaceIndex) {
                            workspaceItem.workspace = workspace;
                        }
                    }
                }

                property real animActive: active ? 1 : 0
                Behavior on animActive {
                    NumberAnimation {
                        duration: 150
                    }
                }
                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: workspaceItem.exists ? (workspaceItem.urgent ? root.urgentColor : (workspaceItem.active ? root.focusedColor : root.activeColor)) : root.inactiveColor
                    implicitWidth: root.dotSize
                    scale: 1 + workspaceItem.animActive * 0.10
                    radius: 15
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = ${workspaceItem.workspaceIndex}})`)
                }
            }
        }
    }

    Connections {
        target: Hyprland.workspaces
        enabled: true

        function onObjectInsertedPost(workspace) {
            root.workspaceAdded(workspace);
        }
    }

    Component.onCompleted: {
        Hyprland.workspaces.values.forEach(workspace => {
            root.workspaceAdded(workspace);
        });
    }
}
