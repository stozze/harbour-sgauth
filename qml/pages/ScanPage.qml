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
                text: "Scan again"
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
                title: "QR code scanner"
            }

            Text {
                id: statusText
                text: ""
                width: parent.width - Theme.paddingLarge*2
                x: Theme.paddingLarge
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
            }
        }
    }

    Connections {
        target: BarcodeScanner
        onBarcodeFound: {
            appwindow.activate();
            statusText.text = "Found code!"
            scanAgainMenu.enabled = true

            pageStack.navigateBack(PageStackAction.Immediate);
            pageStack.currentPage.addAccountFromQRcode(code);
        }
        onBarcodeNotFound: {
            appwindow.activate();
            statusText.text = "No code was found!"
            scanAgainMenu.enabled = true
        }
    }

    function startScanningNow() {
        statusText.text = "Scan in progress!\n\nUse the viewfinder of the camera application to focus on a QR code.\n\nThis feature is still experimental and may not work as expected."
        BarcodeScanner.startScanning();
        scanAgainMenu.enabled = false
    }

    Component.onCompleted: {
        scanpage.startScanningNow();
    }
}
