.import QtQuick.LocalStorage 2.0 as Sql

var currentDatabase = null;
var useTestDatabase = false;

function getDatabase() {
    if (currentDatabase !== null)
        return currentDatabase;

    var dbName = "fi.storbjork.harbour-sgauth.QGoogleAuthStorage";
    if (useTestDatabase)
        dbName = "fi.storbjork.harbour-sgauth.QGoogleAuthStorage-testing";

    var db = Sql.LocalStorage.openDatabaseSync(dbName, "1.0", "Storage for account settings", 100000);

    // Create table
    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS Account(ID INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Key TEXT, SortOrder INTEGER)");
    });

    currentDatabase = db;
    return db;
}

function resetDatabase() {
    var db = getDatabase();

    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE IF EXISTS Account');
    });

    currentDatabase = null;
}

function hasExistingAccounts() {
    var db = getDatabase();
    var accounts = 0;

    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT COUNT(ID) AS NumberOfAccounts FROM Account");
        if (rs.rows.length)
            accounts = rs.rows.item(0).NumberOfAccounts;
    });

    return accounts;
}

function getAccounts() {
    var db = getDatabase();
    var accounts = [];

    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM Account ORDER BY SortOrder ASC");
        for (var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);

            accounts.push({
                "accountId": dbItem.ID,
                "accountName": dbItem.Name,
                "accountKey": dbItem.Key,
                "accountSortOrder": dbItem.SortOrder
            });
        }
    });

    return accounts;
}

function insertAccount(name, key) {
    var db = getDatabase();
    var sortorder = 1;

    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT MAX(SortOrder) AS MaxSortOrder FROM Account");
        if (rs.rows.length)
            sortorder = rs.rows.item(0).MaxSortOrder + 1;
    });

    db.transaction(function(tx) {
        var rs = tx.executeSql("INSERT INTO Account (Name,Key,SortOrder) VALUES(?,?,?)", [name, key, sortorder]);

        return rs.insertId;
    });

    return -1;
}

function updateAccount(id, name, key) {
    var db = getDatabase();

    db.transaction(function(tx) {
        var rs = tx.executeSql("UPDATE Account SET Name=?,Key=? WHERE ID = ?", [name, key, id]);

        return rs.rowsAffected;
    });

    return -1;
}

function removeAccount(id) {
    var db = getDatabase();

    db.transaction(function(tx) {
        var rs = tx.executeSql("DELETE FROM Account WHERE ID = ?", [id]);

        return rs.rowsAffected;
    });

    return -1;
}

function swapAccountSortOrder(firstId, lastId) {
    var db = getDatabase();
    var firstSortOrder = 0;
    var lastSortOrder = 0;

    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT SortOrder FROM Account WHERE Account.ID = ?", [firstId]);
        if (rs.rows.length)
            firstSortOrder = rs.rows.item(0).SortOrder;

        rs = tx.executeSql("SELECT SortOrder FROM Account WHERE Account.ID = ?", [lastId]);
        if (rs.rows.length)
            lastSortOrder = rs.rows.item(0).SortOrder;
    });

    if (firstSortOrder && lastSortOrder) {
        db.transaction(function(tx) {
            var rowsAffected = 0;
            var rs = tx.executeSql("UPDATE Account SET SortOrder = ? WHERE Account.ID = ?", [lastSortOrder,firstId]);
            rowsAffected += rs.RowsAffected;
            rs = tx.executeSql("UPDATE Account SET SortOrder = ? WHERE Account.ID = ?", [firstSortOrder,lastId]);
            rowsAffected += rs.RowsAffected;

            return rowsAffected;
        });
    }

    return -1;
}
