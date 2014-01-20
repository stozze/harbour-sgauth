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
    Q_INVOKABLE QString createOTPAuth(const QString type, const QString label, const QString secret);
};

#endif // QGOOGLEAUTH_H
