#ifndef SGAUTHIMAGEPROVIDER_H
#define SGAUTHIMAGEPROVIDER_H

#include <QImage>
#include <QString>
#include <QQuickImageProvider>

class SGAuthImageProvider : public QQuickImageProvider {
public:
    SGAuthImageProvider() : QQuickImageProvider(QQuickImageProvider::Image) { }
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

    static void setScreenshotImage(QImage img);
    static void setQRCodeImage(QImage img);
    static QImage getScreenshotImage();
    static QImage getQRCodeImage();

private:
    static QImage cachedScreenshotImage;
    static QImage cachedQRCodeImage;
};

#endif // SGAUTHIMAGEPROVIDER_H
