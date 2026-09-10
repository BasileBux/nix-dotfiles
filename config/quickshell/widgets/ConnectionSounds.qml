import QtQuick
import ".."

// Plays toggle sounds on connection state transitions. Set `state` from any
// state enum (Net.ConnectionState, BluetoothDeviceState, ...) and pass the
// matching enum values; only transitions into `connectedState` or from
// `connectingState` back to `disconnectedState` make a sound.
Item {
    property bool _init: false
    property int _prev: -1
    property int connectedState: -2
    property int connectingState: -3
    property int disconnectedState: -4
    property int state: -1

    Component.onCompleted: _init = true
    onStateChanged: {
        if (!_init) {
            _prev = state;
            return;
        }
        if (state === connectedState) {
            Globals.playSound(Globals.sounds.toggleOn);
        } else if (_prev === connectingState && state === disconnectedState) {
            Globals.playSound(Globals.sounds.toggleOff);
        }
        _prev = state;
    }
}
