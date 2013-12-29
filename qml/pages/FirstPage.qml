import QtQuick 2.0
import Sailfish.Silica 1.0
import fi.storbjork.harbour.sgauth.QGoogleAuth 1.0
import "../components/fi.storbjork.harbour-sgauth.QGoogleAuthStorage.js" as QGoogleAuthStorage

Page {
    id: page

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
                    "accountPasscode": ""
                })
            }
        }

        // Now refresh passcodes for all accounts
        for (var i = 0; i < accountsModel.count; i++) {
            var currentlistAccount = accountsModel.get(i)
            accountsModel.setProperty(i, "accountPasscode", QGoogleAuth.generatePin(currentlistAccount.accountKey))
        }

        if (accountsModel.count)
            accountsWrapper.visible = true
        else
            accountsWrapper.visible = false
    }

    SilicaFlickable {
        anchors.fill: parent

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
                        QGoogleAuthStorage.insertAccount(addNewDialog.newAccountName, addNewDialog.newAccountKey)

                        page.refreshPasscodes()
                    })
                }
            }

            MenuItem {
                text: "Refresh now"
                onClicked: page.refreshPasscodes()
                visible: accountsWrapper.visible
            }
        }

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: "SGAuth"
            }

            Text {
                id: noAccountsWrapper
                text: "No accounts found, pull down to add new accounts."
                color: Theme.secondaryColor
                visible: !accountsWrapper.visible
                x: Theme.paddingLarge
                width: column.width - Theme.paddingLarge * 2
                wrapMode: Text.WordWrap
            }

            Column {
                id: accountsWrapper
                x: Theme.paddingLarge
                width: column.width - Theme.paddingLarge * 2
                visible: false

                ProgressBar {
                    id: timeLeftProgressBar
                    minimumValue: 0
                    maximumValue: 30
                    value: QGoogleAuth.timeLeft()
                    valueText: value
                    width: parent.width
                    label: "Time left"
                }

                Rectangle {
                    width: parent.width
                    height: Theme.paddingLarge
                    color: "transparent"
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

                SilicaListView {
                    id: accountsListView
                    x: -Theme.paddingLarge
                    width: parent.width + Theme.paddingLarge * 2
                    model: ListModel {
                        id: accountsModel
                    }
                    height: contentHeight
                    delegate: ListItem {
                        id: accountsDelegate
                        menu: contextMenu

                        width: ListView.view.width
                        height: Theme.itemSizeSmall

                        ListView.onRemove: animateRemoval(accountsDelegate)

                        // Remove account function
                        function remove() {
                            remorseAction("Deleting " + accountName, function() {
                                QGoogleAuthStorage.removeAccount(accountId)

                                page.refreshPasscodes();
                            })
                        }

                        // Edit account function
                        function edit() {
                            var editDialog = pageStack.push(Qt.resolvedUrl("../dialogs/EditAccountDialog.qml"), {"editAccountName": accountName, "editAccountKey": accountKey});

                            editDialog.accepted.connect(function() {
                                QGoogleAuthStorage.updateAccount(accountId, editDialog.editAccountName, editDialog.editAccountKey)

                                accountsModel.setProperty(index, "accountName", editDialog.editAccountName);
                                accountsModel.setProperty(index, "accountKey", editDialog.editAccountKey);

                                page.refreshPasscodes()
                            })
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
                        Column {
                            x: Theme.paddingLarge
                            Label {
                                text: accountName
                                color: accountsDelegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                            }
                            Label {
                                text: accountPasscode
                                color: accountsDelegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeMedium
                            }
                        }

                        // Menu if listitem is pressed
                        Component {
                            id: contextMenu
                            ContextMenu {
                                height: contentHeight
                                MenuItem {
                                    text: "Remove"
                                    onClicked: remove()
                                }
                                MenuItem {
                                    text: "Edit"
                                    onClicked: edit()
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
                                    text: "Copy to clipboard"
                                    onClicked: {
                                        Clipboard.text = accountPasscode
                                    }
                                }
                            }
                        }
                    }
                }
            }
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
                page.refreshPasscodes()
            }

            timeLeftProgressBar.value = timeLeft
        }
    }

    // Initial passcodes
    Component.onCompleted: {
        page.refreshPasscodes()
        timeLeftProgressBar.value = QGoogleAuth.timeLeft()
    }
}


