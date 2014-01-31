import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string keyCheckPasscode
    property int keyCheckCounter
    property string keyCheckName

    Column {
        anchors.fill: parent

        x: Theme.paddingLarge
        width: parent.width - Theme.paddingLarge*2

        DialogHeader {
            acceptText: "Integrity check value"
            width: parent.width
        }

        Text {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge*2
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            text: "To check that you have the correct key value for " + keyCheckName + ", " +
                  "verify that the value here matches the integrity check value provided by the server:"
            wrapMode: Text.WordWrap
        }

        Rectangle {
            color: "transparent"
            width: parent.width
            height: Theme.paddingLarge
        }

        Text {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge*2
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeMedium
            text: "Value: " + keyCheckPasscode
        }

        Rectangle {
            color: "transparent"
            width: parent.width
            height: Theme.paddingMedium
        }

        Text {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge*2
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeMedium
            text: "Counter: " + keyCheckCounter
        }
    }
}
