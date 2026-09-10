import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import ".."

PanelWindow {
    id: root

    // A real model with insert/remove signals is required for the ListView's
    // add/remove/displaced transitions to run (reassigning a plain JS array
    // resets the view and skips them).
    ListModel {
        id: popupModel
    }

    function pushNotification(notification) {
        notification.handler = removeNotification;
        notification.closeTimer.running = true;
        // Prepend: newest on top, previous popups get pushed down.
        popupModel.insert(0, {
            notification: notification
        });
    }
    function removeNotification(notification) {
        // notification.notif.tracked = false;
        notification.closeTimer.running = false;
        for (let i = 0; i < popupModel.count; i++) {
            if (popupModel.get(i).notification === notification) {
                popupModel.remove(i);
                return;
            }
        }
    }
    // Dismiss every popup without untracking the notifications: used when the
    // palette's notifications view opens (it shows the same tracked list).
    // Removes one by one so every popup plays its slide-out animation.
    function dismissAll() {
        for (let i = 0; i < popupModel.count; i++)
            popupModel.get(i).notification.closeTimer.running = false;
        while (popupModel.count > 0)
            popupModel.remove(popupModel.count - 1);
    }

    // Always mapped: mapping a layer-shell surface is async, so showing the
    // window on the first popup would let its add transition finish before
    // the first rendered frame. An empty transparent surface is invisible;
    // the input mask below keeps clicks passing through when there are no
    // popups.
    visible: true

    WlrLayershell.namespace: "shell:notifications"
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    implicitHeight: Globals.notification.unitHeight * Globals.notification.maxVisible + ((Globals.notification.maxVisible - 1) * Globals.space2)
    implicitWidth: Globals.notification.unitWidth

    mask: Region {
        item: inputArea
    }

    anchors {
        right: true
        top: true
    }
    margins {
        right: Globals.radius - 3
        top: Globals.radius - 3
    }

    // Input region matches the actual popup stack (empty -> fully
    // click-through); parts of popups mid-slide aren't clickable, which is
    // fine for a 250ms animation.
    Item {
        id: inputArea

        readonly property int stackHeight: popupModel.count * Globals.notification.unitHeight + Math.max(0, popupModel.count - 1) * Globals.space2

        height: popupModel.count > 0 ? stackHeight : 0
        width: popupModel.count > 0 ? root.implicitWidth : 0

        anchors {
            right: parent.right
            top: parent.top
        }
    }
    ListView {
        id: notificationListView

        anchors.fill: parent
        clip: true
        interactive: false
        model: popupModel
        spacing: Globals.space2

        delegate: NotificationItem {
            required property int index

            // While popups animate over each other, the newest stays on top.
            z: popupModel.count - index
            height: Globals.notification.unitHeight
            removeNotification: root.removeNotification
            width: Globals.notification.unitWidth
            wrapper: true
        }

        add: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                }
                NumberAnimation {
                    property: "x"
                    from: root.implicitWidth
                    to: 0
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
        }
        addDisplaced: Transition {
            NumberAnimation {
                property: "y"
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 200
                }
                NumberAnimation {
                    property: "x"
                    to: root.implicitWidth
                    duration: 250
                    easing.type: Easing.InCubic
                }
            }
        }
        removeDisplaced: Transition {
            NumberAnimation {
                property: "y"
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }
}
