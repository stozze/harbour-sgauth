#ifndef QGOOGLEAUTH_H
#define QGOOGLEAUTH_H

#include <QObject>
#include <QString>
#include <QByteArray>

class QGoogleAuth : public QObject {
    Q_OBJECT
public:
    QGoogleAuth(QObject *parent = 0);
    ~QGoogleAuth();
    Q_INVOKABLE QString generatePin(const QByteArray key);
    Q_INVOKABLE uint timeLeft();
};

#endif // QGOOGLEAUTH_H
