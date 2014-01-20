import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string newAccountName: ""
    property string newAccountKey: ""

    Column {
        anchors.fill: parent

        x: Theme.paddingLarge
        width: parent.width - Theme.paddingLarge*2

        DialogHeader {
            acceptText: "Add new account"
            width: parent.width
        }

        TextField {
            id: nameField
            text: newAccountName
            width: parent.width
            placeholderText: "Account name"
            label: "Account name"
            inputMethodHints: Qt.ImhNoPredictiveText
            focus: true
            EnterKey.enabled: text.length > 0
            EnterKey.onClicked: keyField.focus = true
        }

        Rectangle {
            color: "transparent"
            width: parent.width
            height: Theme.paddingSmall
        }

        Text {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge*2
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            text: "Enter provided key, must be atleast 16 chars long and may contain spaces"
            wrapMode: Text.WordWrap
        }

        Rectangle {
            color: "transparent"
            width: parent.width
            height: Theme.paddingSmall
        }

        TextField {
            id: keyField
            text: newAccountKey
            width: parent.width
            placeholderText: "Account key"
            label: "Account key"
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            EnterKey.enabled: text.length > 0 && canAccept
            EnterKey.onClicked: {
                if (keyField.text.length >= 16)
                    keyField.focus = false
            }
        }
    }

    canAccept: keyField.text.length >= 16 && nameField.text.length >= 1 ? true : false

    onDone: {
        if (result == DialogResult.Accepted) {
            newAccountName = nameField.text
            newAccountKey = keyField.text.toLowerCase()
        }
    }
}
