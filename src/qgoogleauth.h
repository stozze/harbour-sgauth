#ifndef QGOOGLEAUTH_H
#define QGOOGLEAUTH_H

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QVariantMap>

class QGoogleAuth : public QObject {
    Q_OBJECT
public:
    QGoogleAuth(QObject *parent = 0);
    virtual ~QGoogleAuth();

    Q_INVOKABLE QString generatePin(const QByteArray key);
    Q_INVOKABLE uint timeLeft();
    Q_INVOKABLE QVariantMap parseOTPAuth(const QString optauth);
};

#endif // QGOOGLEAUTH_H
