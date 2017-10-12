import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sgauth.BarcodeScanner 1.0

Page {
    id: scanpage

    SilicaFlickable {
        anchors.fill: parent

        // Pulldown menu
        PullDownMenu {
            MenuItem {
                id: scanAgainMenu
                text: qsTr("Scan again")
                enabled: false
                onClicked: {
                    scanpage.startScanningNow();
                }
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                id: header
                title: qsTr("QR code scanner")
            }

            Text {
                id: statusText
                text: ""
                width: parent.width - Theme.paddingLarge*2
                x: Theme.paddingLarge
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
            }

            /*
            // Used for debugging only
            Image {
                id: scanImage
                width: parent.width
                height: parent.width
                source: ""
                cache: false
                fillMode: Image.PreserveAspectFit
            }
            */
        }
    }

    Connections {
        target: BarcodeScanner
        onBarcodeFound: {
            appwindow.activate();
            statusText.text = qsTr("Found code!")
            scanAgainMenu.enabled = true

            pageStack.navigateBack(PageStackAction.Immediate);
            pageStack.currentPage.addAccountFromQRcode(code);
        }
        /*
        // Used for debugging only
        onBarcodeScanAttempt: {
            scanImage.source = ""
            scanImage.source = "image://sgauth/screenshot"
        }
        */
        onBarcodeNotFound: {
            appwindow.activate();
            statusText.text = qsTr("No code was found!")
            scanAgainMenu.enabled = true
        }
    }

    function startScanningNow() {
        statusText.text = qsTr("Scan in progress!\n\nUse the viewfinder of the camera application to focus on a QR code.\n\nThis feature is still experimental and may not work as expected.")
        BarcodeScanner.startScanning();
        scanAgainMenu.enabled = false


    }

    Component.onCompleted: {
        scanpage.startScanningNow();
    }
}
