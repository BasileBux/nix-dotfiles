import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."
import "../modules" as Modules

BarPart {
    id: root
    moduleSizes: [30, 60, 60, 35, 40, 60]

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
        spacing: Globals.spacing
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        Item {
            id: audioModule
            Layout.fillWidth: true
            property int index: 5
            property int popupHeight: 50
            implicitHeight: root.moduleSizes[index]
            Modules.Audio {
                id: audioContent
                popupYpos: root.calculatePopupYpos(audioModule.index, audioModule.popupHeight)
                popupHeight: audioModule.popupHeight
            }
        }
        Item {
            id: bluetoothModule
            Layout.fillWidth: true
            property int index: 4
            property int popupHeight: 400
            implicitHeight: root.moduleSizes[index]
            Modules.Bluetooth {
                id: bluetoothContent
                popupYpos: root.calculatePopupYpos(bluetoothModule.index, bluetoothModule.popupHeight)
                popupHeight: bluetoothModule.popupHeight
            }
        }
        Item {
            id: wifiModule
            Layout.fillWidth: true
            property int index: 3
            property int popupHeight: 360
            implicitHeight: root.moduleSizes[index]
            Modules.Network {
                id: wifiContent
                popupYpos: root.calculatePopupYpos(wifiModule.index, wifiModule.popupHeight)
                popupHeight: wifiModule.popupHeight
            }
        }
        Item {
            id: batteryModule
            Layout.fillWidth: true
            property int index: 2
            property int popupHeight: 190
            implicitHeight: root.moduleSizes[index]
            Modules.Battery {
                id: batteryContent
                popupYpos: root.calculatePopupYpos(batteryModule.index, batteryModule.popupHeight)
                popupHeight: batteryModule.popupHeight
            }
        }
        Item {
            id: clockModule
            Layout.fillWidth: true
            property int index: 1
            property int popupHeight: 60
            implicitHeight: root.moduleSizes[index]
            Modules.Clock {
                id: clockContent
                popupYpos: root.calculatePopupYpos(clockModule.index, clockModule.popupHeight)
                popupHeight: clockModule.popupHeight
            }
        }
        Item {
            id: lockModule
            Layout.fillWidth: true
            implicitHeight: root.moduleSizes[0]
            Modules.Lock {
                id: lockContent
            }
        }
    }
}
