/*
Copyright (c) 2013, Stozze <stozze@rambolo.net>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project.
*/

#include <QtQuick>
#include <sailfishapp.h>
#include "qgoogleauth.h"
#include "barcodescanner.h"
#include "barcodewriter.h"
#include "sgauthimageprovider.h"

// Create singleton QGoogleAuth
static QObject *google_auth_singleton_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    QGoogleAuth *sng = new QGoogleAuth();
    return sng;
}

// Create singleton BarcodeScanner
static QObject *barcode_scanner_singleton_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    BarcodeScanner *sng = new BarcodeScanner();
    return sng;
}

// Create singleton BarcodeWriter
static QObject *barcode_writer_singleton_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    BarcodeWriter *sng = new BarcodeWriter();
    return sng;
}


int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    app->setOrganizationName("");
    app->setOrganizationDomain("");
    app->setApplicationName("harbour-sgauth");

    QString locale = "harbour-sgauth-" + QLocale::system().name();
    QTranslator translator;
    translator.load(locale,SailfishApp::pathTo(QString("i18n")).toLocalFile());
    app->installTranslator(&translator);

    qmlRegisterSingletonType<QGoogleAuth>("harbour.sgauth.QGoogleAuth", 1, 0, "QGoogleAuth", google_auth_singleton_provider);
    qmlRegisterSingletonType<BarcodeScanner>("harbour.sgauth.BarcodeScanner", 1, 0, "BarcodeScanner", barcode_scanner_singleton_provider);
    qmlRegisterSingletonType<BarcodeWriter>("harbour.sgauth.BarcodeWriter", 1, 0, "BarcodeWriter", barcode_writer_singleton_provider);

    view->engine()->addImageProvider("sgauth", new SGAuthImageProvider());

    view->setSource(SailfishApp::pathTo("qml/harbour-sgauth.qml"));
    view->show();

    return app->exec();
}


