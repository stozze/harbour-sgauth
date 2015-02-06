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

    Q_INVOKABLE QString generatePin(const QByteArray key, const QString type = "TOTP", quint64 counter = 1, unsigned digits = 6);
    Q_INVOKABLE uint timeLeft();
    Q_INVOKABLE QVariantMap parseOTPAuth(const QString otpauth);
    Q_INVOKABLE QString createOTPAuth(const QString type, const QString label, const QString secret, quint64 counter, unsigned digits);
};

#endif // QGOOGLEAUTH_H
