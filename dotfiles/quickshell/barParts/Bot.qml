import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."
import "../modules" as Modules

BarPart {
    id: root
    moduleSizes: [25, 40, 42, 28, 30, 39]

    property alias batteryPopup: batteryContent.popup
    property alias clockPopup: clockContent.popup
    property alias wifiPopup: wifiContent.popup
    property alias bluetoothPopup: bluetoothContent.popup
    property alias audioPopup: audioContent.popup
    property alias lockPopup: lockContent.popup

    function calculatePopupYpos(index, popupHeight) {
        return bar.height - ((2 + index) * Globals.spacing + root.sumSizesUntil(index) + (root.moduleSizes[index] / 2) + (popupHeight / 2) + Globals.radius);
    }

    ColumnLayout {
        id: layout
        spacing: Globals.barIconSpacing
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: Globals.spacing
        }
        Item {
            id: audioModule
            Layout.fillWidth: true
            property int index: 5
            property int popupHeight: 285
            property int popupWidth: 440
            implicitHeight: root.moduleSizes[index]
            Modules.Audio {
                id: audioContent
                popupYpos: root.calculatePopupYpos(audioModule.index, audioModule.popupHeight)
                popupHeight: audioModule.popupHeight
                popupWidth: audioModule.popupWidth
            }
        }
        Item {
            id: bluetoothModule
            Layout.fillWidth: true
            property int index: 4
            property int popupHeight: 300
            property int popupWidth: 330
            implicitHeight: root.moduleSizes[index]
            Modules.Bluetooth {
                id: bluetoothContent
                popupYpos: root.calculatePopupYpos(bluetoothModule.index, bluetoothModule.popupHeight)
                popupHeight: bluetoothModule.popupHeight
                popupWidth: bluetoothModule.popupWidth
            }
        }
        Item {
            id: wifiModule
            Layout.fillWidth: true
            property int index: 3
            property int popupHeight: 320
            property int popupWidth: 360
            implicitHeight: root.moduleSizes[index]
            Modules.Network {
                id: wifiContent
                popupYpos: root.calculatePopupYpos(wifiModule.index, wifiModule.popupHeight)
                popupHeight: wifiModule.popupHeight
                popupWidth: wifiModule.popupWidth
            }
        }
        Item {
            id: batteryModule
            Layout.fillWidth: true
            property int index: 2
            property int popupHeight: 160
            property int popupWidth: 280

            implicitHeight: root.moduleSizes[index]
            Modules.Battery {
                id: batteryContent
                popupYpos: root.calculatePopupYpos(batteryModule.index, batteryModule.popupHeight)
                popupHeight: batteryModule.popupHeight
                popupWidth: batteryModule.popupWidth
            }
        }
        Item {
            id: clockModule
            Layout.fillWidth: true
            property int index: 1
            property int popupHeight: 50
            property int popupWidth: 110
            implicitHeight: root.moduleSizes[index]
            Modules.Clock {
                id: clockContent
                popupYpos: root.calculatePopupYpos(clockModule.index, clockModule.popupHeight)
                popupHeight: clockModule.popupHeight
                popupWidth: clockModule.popupWidth
            }
        }
        Item {
            id: lockModule
            Layout.fillWidth: true
            property int index: 0
            property int popupHeight: 0
            property int popupWidth: 0
            implicitHeight: root.moduleSizes[index]
            Modules.Lock {
                id: lockContent
            }
        }
    }
}
