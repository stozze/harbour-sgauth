#ifndef QQRENCODE_CPP
#define QQRENCODE_CPP

#include <QPainter>
#include "qqrencode.h"
#include "qrencode.h"

QQREncoder::QQREncoder() {

}

QImage QQREncoder::encodeString(const QString &data, unsigned int size, unsigned int margin) {
    // Code borrowed from https://code.google.com/p/livepro/source/browse/trunk/gfxengine/QRCodeQtUtil.cpp

    QRcode *qrdata = QRcode_encodeString(qPrintable(data), 0, QR_ECLEVEL_M, QR_MODE_8, 1);

    int datawidth = qrdata->width;
    int realwidth = datawidth * size + margin * 2;

    QImage image(realwidth,realwidth,QImage::Format_Mono);
    memset(image.scanLine(0),0,image.byteCount());

    QPainter painter(&image);
    painter.fillRect(image.rect(),Qt::white);
    for(int x=0;x<datawidth;x++)
        for(int y=0;y<datawidth;y++)
            if(1 & qrdata->data[y*datawidth+x])
                painter.fillRect(QRect(x*size + margin, y*size + margin, size, size), Qt::black);

    painter.end();

    QRcode_free(qrdata);

    return image;
}

#endif // QQRENCODE_CPP
