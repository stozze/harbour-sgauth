# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-sgauth

CONFIG += sailfishapp
QT += dbus

SOURCES += \
    src/qgoogleauth.cpp \
    src/base32.cpp \
    src/hmac.cpp \
    src/harbour-sgauth.cpp \
    src/barcodescanner.cpp \
    src/sgauthimageprovider.cpp \
    src/barcodewriter.cpp

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    qml/dialogs/AddNewAccountDialog.qml \
    qml/dialogs/EditAccountDialog.qml \
    qml/pages/AboutPage.qml \
    harbour-sgauth.desktop \
    rpm/harbour-sgauth.yaml \
    rpm/harbour-sgauth.spec \
    qml/harbour-sgauth.qml \
    harbour-sgauth.png \
    qml/components/harbour.sgauth.QGoogleAuthStorage.js \
    qml/pages/MainPage.qml \
    qml/pages/ScanPage.qml \
    qml/dialogs/CheckKeyDialog.qml

HEADERS += \
    src/qgoogleauth.h \
    src/hmac.h \
    src/base32.h \
    src/barcodescanner.h \
    src/sgauthimageprovider.h \
    src/barcodewriter.h

RESOURCES += \
    harbour-sgauth.qrc

i18n.files = i18n/*.qm
i18n.path = /usr/share/$${TARGET}/i18n

INSTALLS += i18n

lupdate_only {
    SOURCES += qml/*.qml \
              qml/pages/*.qml \
              qml/cover/*.qml \
              qml/dialogs/*.qml

    TRANSLATIONS += i18n/harbour-sgauth-en.ts \
                   i18n/harbour-sgauth-ru.ts
}

include(src/qzxing/QZXing.pri)
include(src/qqrencode/qqrencode.pri)
