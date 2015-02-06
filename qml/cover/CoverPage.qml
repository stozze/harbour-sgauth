import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sgauth.QGoogleAuth 1.0
import "../components/harbour.sgauth.QGoogleAuthStorage.js" as QGoogleAuthStorage

CoverBackground {
    id: coverRoot
    property bool hasTOTPAccounts: false

    function refreshCoverPasscodes() {
        coverRoot.hasTOTPAccounts = false
        // Now refresh passcodes for all cover accounts
        for (var i = 0; i < accountsCoverModel.count; i++) {
            var currentlistAccount = accountsCoverModel.get(i)
            accountsCoverModel.setProperty(i, "accountPasscode", QGoogleAuth.generatePin(currentlistAccount.accountKey,currentlistAccount.accountType,currentlistAccount.accountCounter,currentlistAccount.accountDigits))

            if (currentlistAccount.accountType == "TOTP") {
                coverRoot.hasTOTPAccounts = true
            }
        }
    }

    onStatusChanged: {
        if (status == Cover.Deactivating) {
            accountsCoverModel.clear();
        }
        else if (status == Cover.Activating) {
            accountsCoverModel.clear();
            var accounts = QGoogleAuthStorage.getAccounts();

            // Create listview with top 3 accounts
            for (var i = 0; i < Math.min(accounts.length, 3); i++) {
                accountsCoverModel.append({
                    "accountId": accounts[i]["accountId"],
                    "accountName": accounts[i]["accountName"],
                    "accountKey": accounts[i]["accountKey"],
                    "accountType": accounts[i]["accountType"],
                    "accountCounter": accounts[i]["accountCounter"],
                    "accountDigits": accounts[i]["accountDigits"],
                    "accountPasscode": ""
                })
            }

            coverRoot.refreshCoverPasscodes();
            coverTimeLeftProgressBar.value = QGoogleAuth.timeLeft()
        }
    }

    Image {
        id: appicon
        source: "qrc:/harbour-sgauth.png"
        height: 86
        width: 86
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        opacity: accountsCoverModel.count ? 0.2 : 1.0
    }

    Label {
        id: coverLabel
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.paddingMedium
        text: "SGAuth"
        color: Theme.highlightColor
    }

    Rectangle {
        visible: accountsCoverModel.count ? true : false
        width: parent.width - Theme.paddingSmall * 2
        x: Theme.paddingSmall
        anchors.top: coverLabel.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.bottom: parent.bottom
        color: "transparent"

        ListView {
            id: accountsCover
            anchors.fill: parent

            model: ListModel {
                id: accountsCoverModel
            }
            delegate: ListItem {

                Column {
                    width: parent.width

                    Label {
                        text: accountName
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                        width: parent.width
                    }
                    Label {
                        text: accountPasscode
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                }
            }
        }

        ProgressBar {
            id: coverTimeLeftProgressBar
            minimumValue: 0
            maximumValue: 30
            value: QGoogleAuth.timeLeft()
            width: parent.width
            anchors.bottom: parent.bottom
            visible: coverRoot.hasTOTPAccounts ? true : false
        }
    }

    // Timer to refresh passcodes on cover
    Timer {
        interval: 1000
        running: status == Cover.Active ? true : false
        repeat: true
        onTriggered: {
            var timeLeft = QGoogleAuth.timeLeft()

            // Refresh on 30 and 29 just to make sure we get the latest code
            if (timeLeft == 30 || timeLeft == 29) {
                coverRoot.refreshCoverPasscodes();
            }

            coverTimeLeftProgressBar.value = timeLeft
        }
    }
}


