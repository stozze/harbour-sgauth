#include <QDebug>
#include "sgauthimageprovider.h"

// SGAuth image provider class
QImage SGAuthImageProvider::cachedScreenshotImage;
QImage SGAuthImageProvider::cachedQRCodeImage;

QImage SGAuthImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
    //Q_UNUSED(id)
    Q_UNUSED(size)
    //Q_UNUSED(requestedSize)

    QImage img;

    if (id == "screenshot") {
        img = SGAuthImageProvider::getScreenshotImage();
    }
    else if (id == "qrcode") {
        img = SGAuthImageProvider::getQRCodeImage();
    }

    if (requestedSize.width() != -1 && requestedSize.height() != -1) {
        img.scaled(requestedSize.width(), requestedSize.height());
    }

    return img;
}

void SGAuthImageProvider::setScreenshotImage(QImage img) {
    SGAuthImageProvider::cachedScreenshotImage = img;
}

QImage SGAuthImageProvider::getScreenshotImage() {
    return SGAuthImageProvider::cachedScreenshotImage;
}

void SGAuthImageProvider::setQRCodeImage(QImage img) {
    SGAuthImageProvider::cachedQRCodeImage = img;
}

QImage SGAuthImageProvider::getQRCodeImage() {
    return SGAuthImageProvider::cachedQRCodeImage;
}

