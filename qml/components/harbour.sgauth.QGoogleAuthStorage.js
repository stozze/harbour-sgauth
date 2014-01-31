.import QtQuick.LocalStorage 2.0 as Sql

var currentDatabase = null;
var useTestDatabase = false;

function getDatabase() {
    if (currentDatabase !== null)
        return currentDatabase;

    var dbName = "fi.storbjork.harbour-sgauth.QGoogleAuthStorage";
    if (useTestDatabase)
        dbName = "fi.storbjork.harbour-sgauth.QGoogleAuthStorage-testing";

    var db = Sql.LocalStorage.openDatabaseSync(dbName, "", "Storage for account settings", 100000);
    var lastVersion = 1.1;
    var dbTransactions = [
        // 1.0 => 0
        "CREATE TABLE IF NOT EXISTS Account(ID INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Key TEXT, SortOrder INTEGER)",
        // 1.1 => 1-5
        "ALTER TABLE Account ADD Type TEXT DEFAULT 'TOTP'", // HOTP, TOTP
        "ALTER TABLE Account ADD Algorithm TEXT DEFAULT 'SHA1'", // SHA1, SHA256, SHA512, MD5
        "ALTER TABLE Account ADD Counter INTEGER DEFAULT 1",
        "ALTER TABLE Account ADD Period INTEGER DEFAULT 30",
        "ALTER TABLE Account ADD Digits INTEGER DEFAULT 6"
    ];

    // Initialise or upgrade database
    db.changeVersion(db.version, lastVersion, function(tx) {
        if (db.version < 1.0) {
            tx.executeSql(dbTransactions[0]); // Initial db
            //console.log('Creating initial database 1.0');
        }
        if (db.version < 1.1) {
            tx.executeSql(dbTransactions[1]); // Add type
            tx.executeSql(dbTransactions[2]); // Add algorithm
            tx.executeSql(dbTransactions[3]); // Add counter
            tx.executeSql(dbTransactions[4]); // Add period
            tx.executeSql(dbTransactions[5]); // Add digits
            //console.log('Upgrading database to 1.1');
        }
    });

    // Reload db if needed
    if (db.version != lastVersion) {
        db = Sql.LocalStorage.openDatabaseSync(dbName, "", "Storage for account settings", 100000);
        //console.log('Reloading database due to creation or upgrade...');
    }

    currentDatabase = db;
    return db;
}

function resetDatabase() {
    var db = getDatabase();

    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE IF EXISTS Account');
    });

    db.changeVersion(db.version, "");

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
                "accountSortOrder": dbItem.SortOrder,
                "accountType": dbItem.Type,
                "accountAlgorithm": dbItem.Algorithm,
                "accountCounter": dbItem.Counter,
                "accountPeriod": dbItem.Period,
                "accountDigits": dbItem.Digits
            });
        }
    });

    return accounts;
}

function insertAccount(name, key, type, counter) {
    var db = getDatabase();
    var sortorder = 1;

    db.readTransaction(function(tx) {
        var rs = tx.executeSql("SELECT MAX(SortOrder) AS MaxSortOrder FROM Account");
        if (rs.rows.length)
            sortorder = rs.rows.item(0).MaxSortOrder + 1;
    });

    db.transaction(function(tx) {
        var rs = tx.executeSql("INSERT INTO Account (Name,Key,Type,Counter,SortOrder) VALUES(?,?,?,?,?)", [name, key, type, counter, sortorder]);

        return rs.insertId;
    });

    return -1;
}

function updateAccount(id, name, key, type, counter) {
    var db = getDatabase();

    db.transaction(function(tx) {
        var rs = tx.executeSql("UPDATE Account SET Name=?,Key=?,Type=?,Counter=? WHERE ID = ?", [name, key, type, counter, id]);

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

function incrementCounter(id) {
    var db = getDatabase();

    db.transaction(function(tx) {
        var rs = tx.executeSql("UPDATE Account SET Counter = Counter + 1 WHERE ID = ?", [id]);

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
