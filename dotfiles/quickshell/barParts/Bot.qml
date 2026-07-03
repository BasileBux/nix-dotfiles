import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."
import "../modules" as Modules

BarPart {
    id: root

    property alias batteryPopup: batteryContent.popup
    property alias clockPopup: clockContent.popup
    property alias wifiPopup: wifiContent.popup
    property alias bluetoothPopup: bluetoothContent.popup
    property alias audioPopup: audioContent.popup
    property alias lockPopup: lockContent.popup

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
            property int popupHeight: 185
            property int popupWidth: 340
            implicitHeight: 39
            Modules.Audio {
                id: audioContent
                moduleRef: audioModule
                popupHeight: audioModule.popupHeight
                popupWidth: audioModule.popupWidth
            }
        }
        Item {
            id: bluetoothModule
            Layout.fillWidth: true
            property int popupHeight: 300
            property int popupWidth: 330
            implicitHeight: 30
            Modules.Bluetooth {
                id: bluetoothContent
                moduleRef: bluetoothModule
                popupHeight: bluetoothModule.popupHeight
                popupWidth: bluetoothModule.popupWidth
            }
        }
        Item {
            id: wifiModule
            Layout.fillWidth: true
            property int popupHeight: 320
            property int popupWidth: 360
            implicitHeight: 28
            Modules.Network {
                id: wifiContent
                moduleRef: wifiModule
                popupHeight: wifiModule.popupHeight
                popupWidth: wifiModule.popupWidth
            }
        }
        Item {
            id: batteryModule
            Layout.fillWidth: true
            property int popupHeight: 160
            property int popupWidth: 280
            implicitHeight: 50
            Modules.Battery {
                id: batteryContent
                moduleRef: batteryModule
                popupHeight: batteryModule.popupHeight
                popupWidth: batteryModule.popupWidth
            }
        }
        Item {
            id: clockModule
            Layout.fillWidth: true
            property int popupHeight: 50
            property int popupWidth: 110
            implicitHeight: 40
            Modules.Clock {
                id: clockContent
                moduleRef: clockModule
                popupHeight: clockModule.popupHeight
                popupWidth: clockModule.popupWidth
            }
        }
        Item {
            id: lockModule
            Layout.fillWidth: true
            implicitHeight: 28
            Modules.Lock {
                id: lockContent
            }
        }
    }
}
