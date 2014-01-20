import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sgauth.QGoogleAuth 1.0
import harbour.sgauth.BarcodeWriter 1.0

Dialog {
    property string editAccountName
    property string editAccountKey

    function refreshQRImage() {
        var optauth = QGoogleAuth.createOTPAuth("totp", nameField.text, keyField.text)
        if (optauth.length && nameField.text.length > 0 && keyField.text.length >= 16) {
            BarcodeWriter.encode(optauth);
            scannableImage.source = ""
            scannableImage.source = "image://sgauth/qrcode"
            scannableContainer.visible = true
        }
        else {
            scannableImage.source = ""
            scannableContainer.visible = false
        }
    }

    Column {
        anchors.fill: parent

        x: Theme.paddingLarge
        width: parent.width - Theme.paddingLarge*2

        DialogHeader {
            acceptText: "Save changes"
        }

        TextField {
            id: nameField
            width: parent.width
            text: editAccountName
            placeholderText: "Account name"
            label: "Account name"
            inputMethodHints: Qt.ImhNoPredictiveText
            EnterKey.enabled: text.length > 0
            EnterKey.onClicked: {
                if (nameField.text.length >= 1)
                    nameField.focus = false
            }

            onTextChanged: {
                refreshQRImage()
            }
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
            width: parent.width
            text: editAccountKey
            placeholderText: "Account key"
            label: "Account key"
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            EnterKey.enabled: text.length > 0 && canAccept
            EnterKey.onClicked: {
                if (keyField.text.length >= 16)
                    keyField.focus = false
            }

            onTextChanged: {
                refreshQRImage()
            }
        }

        Column {
            id: scannableContainer
            width: parent.width
            visible: false

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
                text: "Below is a scannable QR code that you can use if you want to import this account on another device:"
                wrapMode: Text.WordWrap
            }

            Rectangle {
                color: "transparent"
                width: parent.width
                height: Theme.paddingLarge
            }

            Image {
                id: scannableImage
                width: parent.width - Theme.paddingLarge*8
                x: Theme.paddingLarge*4
                height: scannableImage.width
                sourceSize.width: scannableImage.width
                sourceSize.height: scannableImage.height
                source: ""
                cache: false
            }
        }
    }

    canAccept: keyField.text.length >= 16 && nameField.text.length >= 1 ? true : false

    onDone: {
        if (result == DialogResult.Accepted) {
            editAccountName = nameField.text
            editAccountKey = keyField.text.toLowerCase()
        }
    }

    onOpened: {
        refreshQRImage()
    }
}
