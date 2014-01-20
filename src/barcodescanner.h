#ifndef BARCODESCANNER_H
#define BARCODESCANNER_H

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QTimer>
#include <QImage>
#include "qqrencode.h"

class BarcodeScanner : public QObject {
    Q_OBJECT
public:
    BarcodeScanner(QObject *parent = 0);
    virtual ~BarcodeScanner();

    Q_INVOKABLE void startScanning();
    Q_INVOKABLE bool isScanning();
    Q_INVOKABLE void stopScanning();

public slots:
    void captureScreen();
    void captureTimeout();

signals:
    void barcodeScanAttempt();
    void barcodeFound(QString code);
    void barcodeNotFound();

private:
    QString cacheFolderLocation;
    QString cacheScreenshotLocation;
    QTimer *captureTimer, *timeoutTimer;
    class QZXing *decoder;
};


#endif // BARCODESCANNER_H
