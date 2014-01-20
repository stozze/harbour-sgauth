#include <QStandardPaths>
#include <QDir>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusConnection>
#include <QDebug>
#include <QProcess>
#include <QPainter>
#include "qzxing.h"
#include "barcodescanner.h"
#include "sgauthimageprovider.h"

BarcodeScanner::BarcodeScanner(QObject *parent) : QObject(parent) {
    // Create cache folder if it doesn't exist
    cacheFolderLocation = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    cacheScreenshotLocation = cacheFolderLocation + "/screenshot.jpg"; // jpg is a lot faster than png in this case
    QDir cacheDir(cacheFolderLocation);

    if (!cacheDir.exists())
        cacheDir.mkpath(".");

    // Capture timer
    captureTimer = new QTimer(this);
    captureTimer->setInterval(500);
    captureTimer->setSingleShot(false);
    connect(captureTimer, SIGNAL(timeout()), this, SLOT(captureScreen()));

    // Timeout timer
    timeoutTimer = new QTimer(this);
    timeoutTimer->setInterval(30000);
    timeoutTimer->setSingleShot(true);
    connect(timeoutTimer, SIGNAL(timeout()), this, SLOT(captureTimeout()));

    // ZXing
    decoder = new QZXing();
}

BarcodeScanner::~BarcodeScanner() {
    delete captureTimer;
    captureTimer = 0;

    delete timeoutTimer;
    timeoutTimer = 0;

    delete decoder;
    decoder = 0;
}

void BarcodeScanner::startScanning() {
    QProcess::startDetached("invoker -s --type=silica-qt5 /usr/bin/jolla-camera");
    captureTimer->start();
    timeoutTimer->start();
}

void BarcodeScanner::stopScanning() {
    QProcess::startDetached("pkill jolla-camera");
    captureTimer->stop();
    timeoutTimer->stop();
}

bool BarcodeScanner::isScanning() {
    return captureTimer->isActive() && timeoutTimer->isActive();
}

void BarcodeScanner::captureTimeout() {
    stopScanning();
    emit barcodeNotFound();
}

void BarcodeScanner::captureScreen() {
    QDBusMessage m = QDBusMessage::createMethodCall("org.nemomobile.lipstick", "/org/nemomobile/lipstick/screenshot", "org.nemomobile.lipstick", "saveScreenshot");
    m << cacheScreenshotLocation;

    QDBusMessage response = QDBusConnection::sessionBus().call(m);
    //qDebug() << response;

    QImage img(cacheScreenshotLocation);
    QVariantHash result = decoder->decodeImageEx(img);
    QList<QVariant> points = result["points"].toList();
    QString code = result["content"].toString();
    //qDebug() << QString("Result: ") << code;
    //qDebug() << QString("Points: ") << QString::number(points.count());

    QPainter painter(&img);
    painter.setPen(Qt::green);

    for (int i=0;i<points.size();i++) {
        QPoint p = points[i].toPoint();
        painter.fillRect(QRect(p.x()-4, p.y()-4, 8, 8), QBrush(Qt::green));

        //qDebug() << QString("Point: ") << QString::number(p.x()) << " " << QString::number(p.y());
    }

    SGAuthImageProvider::setScreenshotImage(img);
    emit barcodeScanAttempt();

    if (code.length()) {
        stopScanning();
        emit barcodeFound(code);
    }
}
