pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick

// Volume + device/stream plumbing. Original sink/source logic stolen from:
// https://github.com/caelestia-dots/shell/blob/main/services/Audio.qml
// Extended with device lists and per-app stream control for the mixer view.
Singleton {
    id: root

    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property string sinkName: sink?.description || sink?.name || "Unknown output"

    // Output devices, capture devices and application streams, rebuilt whenever
    // the PipeWire node graph changes. Streams are kept flat: output and input
    // streams together, no per-device routing.
    property list<PwNode> sinks: []
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool sourceMuted: source?.audio?.muted ?? false
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    property list<PwNode> sources: []
    property list<PwNode> streams: []
    readonly property real volume: sink?.audio?.volume ?? 0

    // Scroll-to-adjust step, shared by the Home volume tile and the media card.
    readonly property real volumeStep: 0.05

    function adjustVolume(up: bool): void {
        setVolume(volume + (up ? volumeStep : -volumeStep));
    }
    function cycleOutput(): void {
        if (sinks.length < 2)
            return;
        const i = sinks.indexOf(sink);
        Pipewire.preferredDefaultAudioSink = sinks[(i + 1) % sinks.length];
    }
    function refreshNodes(): void {
        const newSinks = [];
        const newSources = [];
        const newStreams = [];

        for (const node of Pipewire.nodes.values) {
            if (!node.isStream) {
                if (node.isSink)
                    newSinks.push(node);
                else if (node.audio)
                    newSources.push(node);
            } else if (node.audio) {
                newStreams.push(node);
            }
        }

        sinks = newSinks;
        sources = newSources;
        streams = newStreams;
    }
    function setSourceVolume(volume: real): void {
        if (source?.ready && source?.audio) {
            source.audio.muted = false;
            source.audio.volume = volume;
        }
    }
    function setStreamVolume(stream: PwNode, volume: real): void {
        if (stream?.ready && stream?.audio) {
            stream.audio.muted = false;
            stream.audio.volume = volume;
        }
    }
    function setVolume(volume: real): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = volume;
        }
    }
    function streamName(stream: PwNode): string {
        return stream?.properties["application.name"] || stream?.description || stream?.name || "Unknown app";
    }
    function toggleMute(): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }
    function toggleSourceMute(): void {
        if (source?.ready && source?.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }
    function toggleStreamMute(stream: PwNode): void {
        if (stream?.ready && stream?.audio) {
            stream.audio.muted = !stream.audio.muted;
        }
    }

    // Populate immediately: Pipewire.nodes may already be filled by the time
    // this singleton is created, so onValuesChanged would never fire.
    Component.onCompleted: refreshNodes()

    Connections {
        function onValuesChanged(): void {
            root.refreshNodes();
        }

        target: Pipewire.nodes
    }

    // Track everything so volume/mute bindings stay live, including the
    // current defaults even if the lists lag behind.
    PwObjectTracker {
        objects: [root.sink, root.source, ...root.sinks, ...root.sources, ...root.streams].filter(n => n)
    }
}
