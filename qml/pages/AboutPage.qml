import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutpage

    Column {
        id: column
        width: aboutpage.width
        spacing: Theme.paddingLarge

        PageHeader {
            id: header
            title: qsTr("About SGAuth v%1").arg("0.4-2")
        }

        Text {
            text: qsTr("This is just a simple application that generates TOTP and HOTP passcodes (like Google Authenticator).")+
                  qsTr("The QR code scanning feature is still experimental and may not work as expected.")+
                  "\n\n"+
                  qsTr("Source code is available on GitHub:")+"\n"+
                  "https://github.com/stozze/harbour-sgauth"+
                  "\n\n"+
                  qsTr("Feel free to report issues or contribute via GitHub.")+
                  "\n\n"+
                  "Stozze <stozze@rambolo.net>\n"+
                  "http://www.rambolo.net"
            color: Theme.secondaryColor
            x: Theme.paddingLarge
            font.pixelSize: Theme.fontSizeSmall
            width: column.width - Theme.paddingLarge * 2
            wrapMode: Text.WordWrap
        }

        Text {
            text: "\n\n"+
                  qsTr("SGAuth-icon comes from VisualPharm")+
                  "\nhttp://www.visualpharm.com"
            color: Theme.secondaryColor
            x: Theme.paddingLarge
            font.pixelSize: Theme.fontSizeExtraSmall
            width: column.width - Theme.paddingLarge * 2
            wrapMode: Text.WordWrap
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: pageStack.pop()
    }
}
