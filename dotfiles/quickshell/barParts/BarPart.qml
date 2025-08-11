import Quickshell
import QtQuick

Item {
    anchors.fill: parent
    required property var bar
    required property var moduleSizes

    function sumSizesUntil(index) {
        var sum = 0;
        for (var i = 0; i < index; i++) {
            sum += moduleSizes[i];
        }
        return sum;
    }
}
