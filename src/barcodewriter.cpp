#include "barcodewriter.h"
#include "qqrencode.h"
#include "sgauthimageprovider.h"

BarcodeWriter::BarcodeWriter(QObject *parent) : QObject(parent) {
    encoder = new QQREncoder();
}

BarcodeWriter::~BarcodeWriter() {
    delete encoder;
    encoder = 0;
}

QImage BarcodeWriter::encode(QString data) {
    QImage img = encoder->encodeString(data);

    SGAuthImageProvider::setQRCodeImage(img);

    return img;
}
