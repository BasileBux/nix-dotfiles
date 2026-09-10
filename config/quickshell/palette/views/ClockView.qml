import Quickshell
import QtQuick
import QtQuick.Layouts
import "../widgets" as PWidgets
import "../.."

Item {
    id: root

    property int monthOffset: 0
    readonly property date displayedMonth: new Date(clock.date.getFullYear(), clock.date.getMonth() + monthOffset, 1)
    readonly property int firstWeekday: (displayedMonth.getDay() + 6) % 7
    readonly property var weekdays: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    function handleKey(event) {
        if (event.key === Qt.Key_Left) {
            monthOffset--;
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            monthOffset++;
            event.accepted = true;
        } else if (event.key === Qt.Key_Home) {
            monthOffset = 0;
            event.accepted = true;
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 392
        spacing: Globals.space2

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Text {
                color: Globals.theme.foreground
                font.family: Globals.theme.fontFamily
                font.features: {
                    "tnum": 1
                }
                font.pixelSize: Globals.fonts.clock
                font.weight: Font.DemiBold
                text: Qt.formatDateTime(clock.date, "HH:mm")
            }
            Item {
                Layout.fillWidth: true
            }
            ColumnLayout {
                spacing: Globals.space1
                Text {
                    Layout.alignment: Qt.AlignRight
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.body
                    text: Qt.formatDateTime(clock.date, "dddd")
                }
                Text {
                    Layout.alignment: Qt.AlignRight
                    color: Globals.theme.muted
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    text: Qt.formatDateTime(clock.date, "d MMMM yyyy")
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Text {
                Layout.fillWidth: true
                color: Globals.theme.foreground
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.lead
                font.weight: Font.DemiBold
                text: Qt.formatDateTime(root.displayedMonth, "MMMM yyyy")
            }
            PWidgets.IconButton {
                icon: "chevron-left"
                size: 28
                iconSize: 20
                tooltip: "Previous month · Left"
                onClicked: root.monthOffset--
            }
            PWidgets.IconButton {
                icon: "calendar"
                size: 28
                iconSize: 20
                tooltip: "This month · Home"
                onClicked: root.monthOffset = 0
            }
            PWidgets.IconButton {
                icon: "chevron-right"
                size: 28
                iconSize: 20
                tooltip: "Next month · Right"
                onClicked: root.monthOffset++
            }
        }
        Row {
            Layout.preferredHeight: 20
            Repeater {
                model: root.weekdays
                Text {
                    required property string modelData
                    width: 56
                    height: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    color: Globals.theme.muted
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                }
            }
        }
        Grid {
            columns: 7
            Layout.preferredHeight: 216
            Repeater {
                model: 42
                Item {
                    id: dayCell
                    required property int index
                    readonly property date date: new Date(root.displayedMonth.getFullYear(), root.displayedMonth.getMonth(), index - root.firstWeekday + 1)
                    readonly property bool inMonth: date.getMonth() === root.displayedMonth.getMonth()
                    readonly property bool isToday: date.getFullYear() === clock.date.getFullYear() && date.getMonth() === clock.date.getMonth() && date.getDate() === clock.date.getDate()
                    width: 56
                    height: 36
                    Rectangle {
                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        radius: 14
                        color: Globals.accent
                        visible: dayCell.isToday
                    }
                    Text {
                        anchors.centerIn: parent
                        text: dayCell.date.getDate()
                        color: dayCell.isToday ? Globals.accentContent : Globals.theme.foreground
                        opacity: dayCell.inMonth ? 1 : 0.35
                        font.family: Globals.theme.fontFamily
                        font.features: {
                            "tnum": 1
                        }
                        font.pixelSize: Globals.fonts.body
                        font.weight: dayCell.isToday ? Font.DemiBold : Font.Normal
                    }
                }
            }
        }
    }
}
