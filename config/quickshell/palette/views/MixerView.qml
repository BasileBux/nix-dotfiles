import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services" as Services
import "../widgets" as PWidgets
import "../.."

// Per-app audio mixer: output device + volume, application streams, microphone.
// One surface with three labelled groups separated by space4.
Item {
    id: root

    // The view stays instantiated while the palette is hidden; reset the
    // scroll so it doesn't reopen at the old position.
    onVisibleChanged: if (!visible)
        flick.contentY = 0

    function handleKey(event) {
        if (event.key === Qt.Key_M && (event.modifiers & Qt.ControlModifier)) {
            Services.Audio.toggleMute();
            event.accepted = true;
        } else if (event.key === Qt.Key_Tab) {
            Services.Audio.cycleOutput();
            event.accepted = true;
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: Globals.space2

        Flickable {
            id: flick

            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            contentHeight: Math.max(content.height, height)
            contentWidth: width

            ColumnLayout {
                id: content

                spacing: Globals.space4
                width: flick.width
                y: 0

                RowLayout {
                    Layout.fillWidth: true
                    PWidgets.SectionLabel {
                        label: "Output"
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    PWidgets.Surface {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: Math.min(sinkLabel.implicitWidth + Globals.margin * 2, 480)
                        interactive: true
                        padding: Globals.space2
                        pill: true
                        onClicked: Services.Audio.cycleOutput()
                        Text {
                            id: sinkLabel
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            color: Globals.theme.foreground
                            elide: Text.ElideRight
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.caption
                            text: Services.Audio.sinkName
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Globals.space2

                    PWidgets.IconButton {
                        icon: Services.Audio.muted ? "muted" : "speaker"
                        size: 32

                        onClicked: Services.Audio.toggleMute()
                    }
                    MixerSlider {
                        Layout.fillWidth: true
                        value: Services.Audio.volume

                        onMoved: Services.Audio.setVolume(value)
                    }
                    Text {
                        Layout.preferredWidth: 44
                        color: Globals.theme.muted
                        font.family: Globals.theme.fontFamily
                        font.features: {
                            "tnum": 1
                        }
                        font.pixelSize: Globals.fonts.caption
                        horizontalAlignment: Text.AlignRight
                        text: Globals.percent(isNaN(Services.Audio.volume) ? 0 : Services.Audio.volume)
                    }
                }

                PWidgets.SectionLabel {
                    label: "Applications"
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Globals.space1
                    visible: Services.Audio.streams.length > 0

                    Repeater {
                        model: Services.Audio.streams

                        delegate: StreamRow {
                            stream: modelData
                        }
                    }
                }
                PWidgets.EmptyState {
                    Layout.alignment: Qt.AlignHCenter
                    caption: "Streams appear here when something plays"
                    icon: "speaker"
                    title: "No apps playing"
                    visible: Services.Audio.streams.length === 0
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Globals.space2
                    visible: Services.Audio.source !== null

                    PWidgets.SectionLabel {
                        label: "Microphone"
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Globals.space2

                        PWidgets.IconButton {
                            icon: Services.Audio.sourceMuted ? "microphone-muted" : "microphone"
                            size: 32

                            onClicked: Services.Audio.toggleSourceMute()
                        }
                        MixerSlider {
                            Layout.fillWidth: true
                            value: Services.Audio.sourceVolume

                            onMoved: Services.Audio.setSourceVolume(value)
                        }
                        Text {
                            Layout.preferredWidth: 44
                            color: Globals.theme.muted
                            font.family: Globals.theme.fontFamily
                            font.features: {
                                "tnum": 1
                            }
                            font.pixelSize: Globals.fonts.caption
                            horizontalAlignment: Text.AlignRight
                            text: Globals.percent(Services.Audio.sourceVolume)
                        }
                    }
                }
            }
        }
    }

    // The palette slider look: a recessed track with an accent fill that follows
    // the pointer exactly (no animation while dragging).
    component MixerSlider: Slider {
        id: slider

        from: 0
        to: 1

        background: Rectangle {
            color: Globals.controlTrack
            height: implicitHeight
            implicitHeight: 6
            implicitWidth: 10
            radius: height / 2
            width: slider.availableWidth
            // Center the track on the handle's axis instead of the top edge.
            y: slider.topPadding + (slider.availableHeight - height) / 2

            Rectangle {
                color: Globals.accent
                height: parent.height
                radius: height / 2
                width: slider.visualPosition * parent.width
            }
        }
        handle: Rectangle {
            color: Globals.theme.foreground
            implicitHeight: 14
            implicitWidth: 14
            radius: width / 2
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
        }
    }

    component StreamRow: RowLayout {
        id: streamRow

        readonly property bool muted: stream?.audio?.muted ?? false
        readonly property string name: Services.Audio.streamName(stream)
        property PwNode stream

        Layout.fillWidth: true
        Layout.preferredHeight: 44
        spacing: Globals.space2

        PWidgets.IconButton {
            icon: streamRow.muted ? "muted" : "speaker"
            size: 32
            tooltip: streamRow.muted ? "Unmute application" : "Mute application"
            onClicked: Services.Audio.toggleStreamMute(streamRow.stream)
        }
        Text {
            Layout.preferredWidth: 160
            Layout.maximumWidth: 160
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.pixelSize: Globals.fonts.body
            elide: Text.ElideRight
            text: streamRow.name
        }
        MixerSlider {
            Layout.fillWidth: true
            value: streamRow.stream?.audio?.volume ?? 0
            onMoved: Services.Audio.setStreamVolume(streamRow.stream, value)
        }
        Text {
            Layout.preferredWidth: 44
            color: Globals.theme.muted
            font.family: Globals.theme.fontFamily
            font.features: {
                "tnum": 1
            }
            font.pixelSize: Globals.fonts.caption
            horizontalAlignment: Text.AlignRight
            text: Globals.percent(streamRow.stream?.audio?.volume ?? 0)
        }
    }
}
