import QtQuick
import "../.."

// Eyebrow above a group. "OUTPUT" / "Applications" / "exit nodes" were each
// spelled differently across views; one component means one voice.
Text {
    id: root

    property string label

    color: Globals.theme.muted
    font.family: Globals.theme.fontFamily
    font.pixelSize: Globals.fonts.micro
    font.letterSpacing: 0.6
    font.weight: Font.DemiBold
    text: root.label.toUpperCase()
}
