#include <QtEndian>
#include <QDateTime>
#include <QTimer>
#include <QtMath>
#include <QUrl>
#include <QUrlQuery>
#include "base32.h"
#include "hmac.h"
#include "qgoogleauth.h"

QGoogleAuth::QGoogleAuth(QObject *parent) : QObject(parent) {
}

QGoogleAuth::~QGoogleAuth() {
}

uint QGoogleAuth::timeLeft() {
    quint64 timenow = QDateTime::currentDateTime().toTime_t();
    quint64 timelast = (timenow / 30) * 30;
    quint64 timenext = timelast + 30;

    return (uint)(timenext - timenow);
}

QString QGoogleAuth::generatePin(const QByteArray key)
{
    quint64 time = QDateTime::currentDateTime().toTime_t();
    quint64 current = qToBigEndian(time / 30);

    int secretLen = (key.length() + 7) / 8 * 5;
    quint8 secret[100];
    int res = Base32::base32_decode(reinterpret_cast<const quint8 *>(key.constData()), secret, secretLen);
    QByteArray hmac = HMAC::hmacSha1(QByteArray(reinterpret_cast<const char *>(secret), res), QByteArray((char*)&current, sizeof(current)));

    int offset = (hmac[hmac.length() - 1] & 0xf);
    int binary =
            ((hmac[offset] & 0x7f) << 24)
            | ((hmac[offset + 1] & 0xff) << 16)
            | ((hmac[offset + 2] & 0xff) << 8)
            | (hmac[offset + 3] & 0xff);

    int password = binary % 1000000;
    return QString("%1").arg(password, 6, 10, QChar('0'));
}

QVariantMap QGoogleAuth::parseOTPAuth(const QString optauth) {
    QVariantMap result;
    QUrl otpurl(optauth);
    QUrlQuery otpquery(otpurl.query());

    result["type"] = otpurl.host();
    result["label"] = otpurl.path().mid(1);
    result["secret"] = otpquery.hasQueryItem("secret") ? otpquery.queryItemValue("secret") : "";
    result["issuer"] = otpquery.hasQueryItem("issuer") ? otpquery.queryItemValue("issuer") : "";

    return result;
}

QString QGoogleAuth::createOTPAuth(const QString type, const QString label, const QString secret) {
    QString formattedLabel = QString(label).replace(QString(":"), QString(" ")).replace(QString("?"), QString(""));
    QString formattedSecret = secret.toUpper().replace(QString(" "), QString(""));

    QUrl otpurl("otpauth://" + type + "/SGAuth:" + formattedLabel + "?secret=" + formattedSecret + "&issuer=SGAuth");
    return otpurl.toEncoded();
}
