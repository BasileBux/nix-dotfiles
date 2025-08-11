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

    property color inactiveColor: Globals.theme.foreground
    property color focusedColor: Globals.theme.accent1
    property color activeColor: Globals.theme.accent3

    ColumnLayout {
        spacing: Globals.workspacesGap
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        Repeater {
            model: 10
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Item {
                id: workspaceItem
                height: 8
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
                    width: Globals.barWidth * 0.4
                    scale: 1 + animActive * 0.30
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
