#ifndef QQRENCODE_H
#define QQRENCODE_H

#include <QObject>
#include <QImage>

class QQREncoder : QObject {
    Q_OBJECT
public:
    QQREncoder();

    QImage encodeString(const QString &data, unsigned int size = 5, unsigned int margin = 4);
};

#endif // QQRENCODE_H
