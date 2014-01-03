import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        id: appicon
        source: "qrc:/harbour-sgauth.png"
        height: 86
        width: 86
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
    }

    Label {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.paddingLarge
        text: "SGAuth"
    }
}


