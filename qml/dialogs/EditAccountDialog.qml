import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string editAccountName
    property string editAccountKey

    Column {
        spacing: 10
        anchors.fill: parent

        DialogHeader {
            acceptText: "Save changes"
            width: parent.width
        }

        Label {
            x: Theme.paddingLarge
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeMedium
        }

        TextField {
            id: nameField
            width: parent.width
            text: editAccountName
            placeholderText: "Account name"
            label: "Account name"
            inputMethodHints: Qt.ImhNoPredictiveText
            focus: true
            EnterKey.enabled: text.length > 0
            EnterKey.onClicked: keyField.focus = true
        }

        Text {
            x: Theme.paddingLarge
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            text: "Enter provided key, must be atleast 16 chars long and may contain spaces"
            wrapMode: Text.WordWrap
            width: parent.width
        }

        TextField {
            id: keyField
            width: parent.width
            text: editAccountKey
            placeholderText: "Account key"
            label: "Account key"
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            EnterKey.enabled: text.length > 0 && canAccept
            EnterKey.onClicked: accept()
        }
    }

    canAccept: keyField.text.length >= 16 && nameField.text.length >= 1 ? true : false

    onDone: {
        if (result == DialogResult.Accepted) {
            editAccountName = nameField.text
            editAccountKey = keyField.text.toLowerCase()
        }
    }
}
