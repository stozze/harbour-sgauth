#ifndef BARCODESCANNER_H
#define BARCODESCANNER_H

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QTimer>
#include <QImage>
#include <QQuickImageProvider>

class BarcodeScannerImageProvider : public QQuickImageProvider {
public:
    BarcodeScannerImageProvider() : QQuickImageProvider(QQuickImageProvider::Image) { }
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

    void setCachedImage(QImage img);

private:
    QImage cachedImage;
};

class BarcodeScanner : public QObject {
    Q_OBJECT
public:
    BarcodeScanner(QObject *parent = 0);
    virtual ~BarcodeScanner();

    Q_INVOKABLE void startScanning();
    Q_INVOKABLE bool isScanning();
    Q_INVOKABLE void stopScanning();

    BarcodeScannerImageProvider *getImageProvider();

public slots:
    void captureScreen();
    void captureTimeout();

signals:
    void barcodeFound(QString code);
    void barcodeNotFound();

private:
    QString cacheFolderLocation;
    QString cacheScreenshotLocation;
    QTimer *captureTimer, *timeoutTimer;
    BarcodeScannerImageProvider *imageProvider;
    class QZXing *decoder;
};


#endif // BARCODESCANNER_H
