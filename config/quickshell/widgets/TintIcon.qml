import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias color: btn.icon.color

    // Icon basename from the shell's icons/ directory, without the extension.
    property string name

    Button {
        id: btn

        anchors.fill: parent
        // Render only: the owning tile/button handles pointer input.
        enabled: false
        padding: 0
        leftInset: 0
        rightInset: 0
        topInset: 0
        bottomInset: 0
        display: AbstractButton.IconOnly
        focusPolicy: Qt.NoFocus
        // Artwork sits inside the layout slot without shrinking the hit target.
        icon.height: Math.round(parent.height * 0.82)
        // Resolved here, not by the caller: a relative source on the aliased
        // icon property is resolved against this file, so callers must not
        // pass paths.
        icon.source: root.name === "" ? "" : Qt.resolvedUrl("../icons/" + root.name + ".svg")
        icon.width: Math.round(parent.width * 0.82)

        background: Item {}
    }
}
