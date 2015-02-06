import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sgauth.QGoogleAuth 1.0
import harbour.sgauth.BarcodeWriter 1.0

Dialog {
    property string editAccountName
    property string editAccountKey
    property string editAccountType
    property int editAccountCounter
    property int editAccountDigits

    function refreshQRImage() {
        var counterValue = parseInt(counterField.text,10) || 1;
        if (counterValue < 1)
            counterValue = 1;
        var accountType = typeComboBox.currentIndex == 0 ? "TOTP" : "HOTP";
        var digitsValue = parseInt(digitsField.text,10) || 6;

        var otpauth = QGoogleAuth.createOTPAuth(accountType, nameField.text, keyField.text, counterValue, digitsValue)
        if (otpauth.length && nameField.text.length > 0 && keyField.text.length >= 16 && (accountType == "TOTP" || (accountType == "HOTP" && counterValue >= 1))) {
            BarcodeWriter.encode(otpauth);
            scannableImage.source = ""
            scannableImage.source = "image://sgauth/qrcode"
            scannableContainer.visible = true
        }
        else {
            scannableImage.source = ""
            scannableContainer.visible = false
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentWrapperColumn.height

        Column {
            id: contentWrapperColumn
            width: parent.width

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
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
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
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.enabled: text.length > 0 && canAccept
                EnterKey.onClicked: {
                    if (keyField.text.length >= 16)
                        digitsField.focus = true
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

            TextField {
                id: digitsField
                width: parent.width
                text: editAccountDigits
                placeholderText: "Code digits"
                label: "Code digits"
                validator: IntValidator { bottom: 1; top: 8; }
                inputMethodHints: Qt.ImhDigitsOnly
                EnterKey.onClicked: digitsField.focus = false
                onTextChanged: {
                    refreshQRImage();
                }
            }

            ComboBox {
                id: typeComboBox
                width: parent.width
                label: "Account type"
                currentIndex: editAccountType == "TOTP" ? 0 : 1

                menu: ContextMenu {
                    MenuItem { text: "Time-based" }
                    MenuItem { text: "Counter-based" }
                }

                onCurrentIndexChanged: {
                    refreshQRImage();
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
                text: editAccountCounter
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: "Counter value"
                placeholderText: "Counter value"
                visible: typeComboBox.currentIndex == 1 ? true : false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.enabled: parseInt(text,10) >= 1
                EnterKey.onClicked: {
                    if (parseInt(counterField.text,10) >= 1)
                        counterField.focus = false
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
                    height: Theme.paddingLarge
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

                Rectangle {
                    color: "transparent"
                    width: parent.width
                    height: Theme.paddingLarge
                }
            }
        }
    }

    canAccept: keyField.text.length >= 16 && nameField.text.length >= 1 && digitsField.text.length >= 1 ? true : false

    onDone: {
        if (result == DialogResult.Accepted) {
            editAccountName = nameField.text
            editAccountKey = keyField.text.toLowerCase()
            editAccountCounter = parseInt(counterField.text,10) || 1
            if (editAccountCounter < 1)
                editAccountCounter = 1;
            editAccountDigits = parseInt(digitsField.text,10);
            editAccountType = typeComboBox.currentIndex == 0 ? "TOTP" : "HOTP"
        }
    }

    onOpened: {
        refreshQRImage()
    }
}
