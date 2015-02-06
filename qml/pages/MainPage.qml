import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sgauth.QGoogleAuth 1.0
import "../components/harbour.sgauth.QGoogleAuthStorage.js" as QGoogleAuthStorage
import harbour.sgauth.BarcodeScanner 1.0

Page {
    id: mainpage
    property bool hasTOTPAccounts: false

    function refreshPasscodes() {
        var accounts = QGoogleAuthStorage.getAccounts();

        // Create account listview
        if (accountsModel.count != accounts.length) {
            accountsModel.clear();

            for (var i = 0; i < accounts.length; i++) {
                accountsModel.append({
                    "accountId": accounts[i]["accountId"],
                    "accountName": accounts[i]["accountName"],
                    "accountKey": accounts[i]["accountKey"],
                    "accountType": accounts[i]["accountType"],
                    "accountCounter": accounts[i]["accountCounter"],
                    "accountDigits": accounts[i]["accountDigits"],
                    "accountPasscode": ""
                })
            }
        }

        // Now refresh passcodes for all accounts
        mainpage.hasTOTPAccounts = false
        for (var i = 0; i < accountsModel.count; i++) {
            var currentlistAccount = accountsModel.get(i)
            accountsModel.setProperty(i, "accountPasscode", QGoogleAuth.generatePin(currentlistAccount.accountKey,currentlistAccount.accountType,currentlistAccount.accountCounter,currentlistAccount.accountDigits))
            if (currentlistAccount.accountType == "TOTP")
                mainpage.hasTOTPAccounts = true;
        }

        if (accountsModel.count)
            accountsWrapper.visible = true
        else
            accountsWrapper.visible = false
    }

    function addAccountFromQRcode(code) {
        var parsedCode = {
            "label": "",
            "secret": "",
            "counter": 1,
            "type": "TOTP"
        }
        // Parse otpauth
        if (code.indexOf("otpauth://totp") !== -1 || code.indexOf("otpauth://hotp") !== -1) {
            var tmpCode = QGoogleAuth.parseOTPAuth(code);
            parsedCode["label"] = tmpCode["label"];
            parsedCode["secret"] = tmpCode["secret"];
            parsedCode["type"] = tmpCode["type"].toUpperCase();
            parsedCode["counter"] = tmpCode["counter"];
            parsedCode["digits"] = tmpCode["digits"];
        }
        else {
            parsedCode["secret"] = code;
        }

        var addNewDialog = pageStack.push(Qt.resolvedUrl("../dialogs/AddNewAccountDialog.qml"), {
                                              "newAccountName": parsedCode["label"],
                                              "newAccountKey": parsedCode["secret"],
                                              "newAccountType": parsedCode["type"],
                                              "newAccountCounter": parsedCode["counter"],
                                              "newAccountDigits": parsedCode["digits"],
                                          });

        addNewDialog.accepted.connect(function() {
            QGoogleAuthStorage.insertAccount(addNewDialog.newAccountName, addNewDialog.newAccountKey, addNewDialog.newAccountType, addNewDialog.newAccountCounter, addNewDialog.newAccountDigits)

            mainpage.refreshPasscodes()
        })
    }

    // List model for accounts
    ListModel {
        id: accountsModel
    }

    SilicaFlickable {
        anchors.fill: parent
        clip: true
        interactive: !accountsListView.flicking

        // Pulldown menu
        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
                }
            }
            MenuItem {
                text: "Add new account"
                onClicked: {
                    var addNewDialog = pageStack.push(Qt.resolvedUrl("../dialogs/AddNewAccountDialog.qml"));

                    addNewDialog.accepted.connect(function() {
                        QGoogleAuthStorage.insertAccount(addNewDialog.newAccountName, addNewDialog.newAccountKey, addNewDialog.newAccountType, addNewDialog.newAccountCounter, addNewDialog.newAccountDigits)

                        mainpage.refreshPasscodes()
                    })
                }
            }
            MenuItem {
                text: "Scan QR code (experimental)"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ScanPage.qml"));
                }
            }
            MenuItem {
                text: "Refresh now"
                onClicked: mainpage.refreshPasscodes()
                visible: accountsWrapper.visible && mainpage.hasTOTPAccounts
            }
        }

        PageHeader {
            id: pageHeader
            title: "SGAuth"
        }

        Column {
            id: column
            width: parent.width - Theme.paddingLarge*2
            x: Theme.paddingLarge
            anchors.top: pageHeader.bottom

            Text {
                id: noAccountsWrapper
                text: "No accounts found, pull down to add new accounts."
                color: Theme.secondaryColor
                visible: !accountsWrapper.visible
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Column {
                id: accountsWrapper
                width: parent.width
                visible: false

                ProgressBar {
                    id: timeLeftProgressBar
                    minimumValue: 0
                    maximumValue: 30
                    value: QGoogleAuth.timeLeft()
                    valueText: value
                    width: parent.width
                    label: "Time left"
                    visible: mainpage.hasTOTPAccounts ? true : false
                }

                Rectangle {
                    width: parent.width
                    height: Theme.paddingLarge
                    color: "transparent"
                    visible: mainpage.hasTOTPAccounts ? true : false
                }

                Text {
                    id: helperText
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: "Enter this verification code if prompted during account sign-in:"
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Rectangle {
                    width: parent.width
                    height: Theme.paddingLarge
                    color: "transparent"
                }
            }
        }

        SilicaListView {
            id: accountsListView
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            anchors.top: column.bottom
            anchors.bottom: parent.bottom
            width: parent.width
            model: accountsModel

            delegate: ListItem {
                id: accountsDelegate
                width: parent.width
                menu: contextMenu

                ListView.onRemove: animateRemoval(accountsDelegate)

                // Remove account function
                function remove() {
                    remorseAction("Deleting " + accountName, function() {
                        QGoogleAuthStorage.removeAccount(accountId)

                        mainpage.refreshPasscodes();
                    })
                }

                // Edit account function
                function edit() {
                    var editDialog = pageStack.push(Qt.resolvedUrl("../dialogs/EditAccountDialog.qml"), {"editAccountName": accountName, "editAccountKey": accountKey, "editAccountType": accountType, "editAccountCounter": accountCounter, "editAccountDigits": accountDigits });

                    editDialog.accepted.connect(function() {
                        QGoogleAuthStorage.updateAccount(accountId, editDialog.editAccountName, editDialog.editAccountKey, editDialog.editAccountType, editDialog.editAccountCounter, editDialog.editAccountDigits)

                        accountsModel.setProperty(index, "accountName", editDialog.editAccountName);
                        accountsModel.setProperty(index, "accountKey", editDialog.editAccountKey);
                        accountsModel.setProperty(index, "accountType", editDialog.editAccountType);
                        accountsModel.setProperty(index, "accountCounter", editDialog.editAccountCounter);
                        accountsModel.setProperty(index, "accountDigits", editDialog.editAccountDigits);

                        mainpage.refreshPasscodes()
                    })
                }

                // Key check function
                function keycheck() {
                    var checkDialog = pageStack.push(Qt.resolvedUrl("../dialogs/CheckKeyDialog.qml"), {
                        "keyCheckPasscode": QGoogleAuth.generatePin(accountKey,"HOTP",0,accountDigits),
                        "keyCheckCounter": parseInt(accountCounter,10),
                        "keyCheckName": accountName
                    });
                }

                // Move account up function
                function moveUp() {
                    QGoogleAuthStorage.swapAccountSortOrder(accountsModel.get(index).accountId, accountsModel.get(index-1).accountId);
                    accountsModel.move(index,index-1,1);
                }

                // Move account down function
                function moveDown() {
                    QGoogleAuthStorage.swapAccountSortOrder(accountsModel.get(index).accountId, accountsModel.get(index+1).accountId);
                    accountsModel.move(index,index+1,1);
                }

                // List item content (name and passcode)
                Rectangle {
                    width: parent.width - Theme.paddingLarge*2
                    x: Theme.paddingLarge
                    color: "transparent"
                    height: contentHeight

                    IconButton {
                        id: rowIconButton
                        width: 64
                        height: 64
                        y: 9
                        icon.source: accountType == "TOTP" ? "image://theme/icon-m-time-date" : "image://theme/icon-m-refresh"
                        onClicked: {
                            if (accountType == "TOTP") {
                                accountsModel.setProperty(index, "accountPasscode", QGoogleAuth.generatePin(accountKey,accountType,accountCounter,accountDigits))
                            }
                            else if (accountType == "HOTP") {
                                var nextCounterValue = parseInt(accountCounter,10) + 1;
                                remorseAction("Next passcode for " + accountName, function() {
                                    accountsModel.setProperty(index, "accountPasscode", QGoogleAuth.generatePin(accountKey,accountType,nextCounterValue,accountDigits))
                                    accountsModel.setProperty(index, "accountCounter", nextCounterValue)
                                    QGoogleAuthStorage.incrementCounter(accountId)
                                }, 2000)
                            }
                        }
                    }


                    Column {
                        anchors.left: rowIconButton.right
                        anchors.right: parent.right

                        Label {
                            text: accountName
                            color: accountsDelegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            truncationMode: TruncationMode.Fade
                            width: parent.width - Theme.paddingMedium
                            x: Theme.paddingMedium
                        }
                        Label {
                            text: accountPasscode
                            color: accountsDelegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeMedium
                            width: parent.width - Theme.paddingMedium
                            x: Theme.paddingMedium
                        }
                    }
                }

                // Menu if listitem is pressed
                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: "Copy to clipboard"
                            onClicked: {
                                Clipboard.text = accountPasscode
                            }
                        }
                        MenuItem {
                            text: "Move up"
                            onClicked: {
                                moveUp()
                            }
                            visible: index > 0
                        }
                        MenuItem {
                            text: "Move down"
                            onClicked: {
                                moveDown()
                            }
                            visible: index < accountsModel.count-1
                        }
                        MenuItem {
                            text: "Check key value"
                            visible: accountType == 'HOTP' ? true : false
                            onClicked: keycheck()
                        }
                        MenuItem {
                            text: "Edit"
                            onClicked: edit()
                        }
                        MenuItem {
                            text: "Remove"
                            onClicked: remove()
                        }
                    }
                }
            }

            VerticalScrollDecorator { flickable: accountsListView }
        }

    }

    // Timer to refresh passcodes
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var timeLeft = QGoogleAuth.timeLeft()

            // Refresh on 30 and 29 just to make sure we get the latest code
            if (timeLeft == 30 || timeLeft == 29) {
                mainpage.refreshPasscodes()
            }

            timeLeftProgressBar.value = timeLeft
        }
    }

    // Initial passcodes
    Component.onCompleted: {
        mainpage.refreshPasscodes()
        timeLeftProgressBar.value = QGoogleAuth.timeLeft()
    }
}


