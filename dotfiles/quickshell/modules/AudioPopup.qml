import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services
import ".."

Item {
    id: root
    anchors {
        fill: parent
        leftMargin: Globals.spacing
        rightMargin: Globals.spacing
    }

    RowLayout {
        anchors.fill: parent
        Item {
            implicitWidth: 40
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            Button {
                id: muteButton
                background: Rectangle {
                    color: "transparent"
                }
                icon.source: "../icons/muted.svg"
                icon.color: Globals.theme.foreground
                icon.height: parent.height * 0.7
                icon.width: parent.height * 0.7
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    Services.Audio.toggleMute();
                }
                onEntered: {
                    muteButton.icon.color = Globals.theme.accent2;
                }
                onExited: {
                    muteButton.icon.color = Globals.theme.foreground;
                }
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Slider {
                id: volumeSlider
                anchors.fill: parent
                from: 0
                value: Services.Audio.volume
                to: 1
                onMoved: {
                    Services.Audio.setVolume(volumeSlider.value);
                }

                background: Rectangle {
                    color: Globals.theme.muted
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 10
                    implicitHeight: 4
                    width: volumeSlider.availableWidth
                    height: implicitHeight
                    radius: height / 2

                    Rectangle {
                        color: Globals.theme.accent1
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        radius: height / 2
                    }
                }

                handle: Rectangle {
                    x: volumeSlider.visualPosition * (volumeSlider.availableWidth - width) + volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: width / 2
                    color: Globals.theme.foreground
                }
            }
        }
    }
}
