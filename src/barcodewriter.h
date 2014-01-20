#ifndef BARCODEWRITER_H
#define BARCODEWRITER_H

#include <QObject>
#include <QString>
#include <QImage>

class BarcodeWriter : public QObject {
    Q_OBJECT
public:
    BarcodeWriter(QObject *parent = 0);
    virtual ~BarcodeWriter();

    Q_INVOKABLE QImage encode(QString data);

private:
    class QQREncoder *encoder;
};

#endif // BARCODEWRITER_H
