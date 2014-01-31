import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string newAccountName: ""
    property string newAccountKey: ""
    property string newAccountType: "TOTP"
    property int newAccountCounter: 1

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
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
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
            EnterKey.iconSource: typeComboBox.currentIndex == 1 ? "image://theme/icon-m-enter-next" : "image://theme/icon-m-enter-close"
            EnterKey.enabled: text.length >= 16
            EnterKey.onClicked: {
                if (keyField.text.length >= 16)
                    keyField.focus = false
            }
        }

        Rectangle {
            color: "transparent"
            width: parent.width
            height: Theme.paddingSmall
        }

        ComboBox {
            id: typeComboBox
            width: parent.width
            label: "Account type"
            currentIndex: newAccountType == "TOTP" ? 0 : 1

            menu: ContextMenu {
                MenuItem { text: "Time-based" }
                MenuItem { text: "Counter-based" }
            }
        }

        Rectangle {
            color: "transparent"
            width: parent.width
            height: Theme.paddingSmall
            visible: typeComboBox.currentIndex == 1 ? true : false
        }

        TextField {
            id: counterField
            text: newAccountCounter
            width: parent.width
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            label: "Counter initial value"
            placeholderText: "Counter initial value"
            visible: typeComboBox.currentIndex == 1 ? true : false
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.enabled: parseInt(text,10) >= 1
            EnterKey.onClicked: {
                if (parseInt(counterField.text,10) >= 1)
                    counterField.focus = false
            }
        }

    }

    canAccept: keyField.text.length >= 16 && nameField.text.length >= 1 && (typeComboBox.currentIndex == 0 || parseInt(counterField.text,10) >= 1) ? true : false

    onDone: {
        if (result == DialogResult.Accepted) {
            newAccountName = nameField.text
            newAccountKey = keyField.text.toLowerCase()
            newAccountCounter = parseInt(counterField.text,10) || 1
            if (newAccountCounter < 1)
                newAccountCounter = 1;

            newAccountType = typeComboBox.currentIndex == 0 ? "TOTP" : "HOTP"
        }
    }
}
