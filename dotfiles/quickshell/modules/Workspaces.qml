import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    anchors.fill: parent
    property int popupYpos: 0

    signal workspaceAdded(workspace: HyprlandWorkspace)
    property int workspaceCount: 0

    readonly property color inactiveColor: Globals.theme.foreground
    readonly property color focusedColor: Globals.theme.accent1
    readonly property color activeColor: Globals.theme.accent3
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
                    color: workspaceItem.exists ? workspaceItem.active ? focusedColor : activeColor : inactiveColor
                    implicitWidth: root.dotSize
                    scale: 1 + animActive * 0.10
                    radius: 15
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch(`workspace ${workspaceIndex}`)
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
