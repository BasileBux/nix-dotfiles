import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    // These properties are in the context and not individual lock surfaces
    // so all surfaces can share the same state.
    property string currentText: ""
    property bool showFailure: false
    property bool unlockInProgress: false

    signal failed
    signal unlocked

    function tryUnlock() {
        if (currentText === "")
            return;

        root.unlockInProgress = true;
        pam.start();
    }

    // Clear the failure text once the user starts typing.
    onCurrentTextChanged: showFailure = false

    PamContext {
        id: pam

        config: "password.conf"

        // Its best to have a custom pam config for quickshell, as the system one
        // might not be what your interface expects, and break in some way.
        // This particular example only supports passwords.
        configDirectory: "pam"

        // pam_unix won't send any important messages so all we need is the completion status.
        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocked();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }

            root.unlockInProgress = false;
        }

        // pam_unix will ask for a response for the password prompt
        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
        }
    }
}
