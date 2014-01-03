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

SOURCES += \
    src/qgoogleauth.cpp \
    src/base32.cpp \
    src/hmac.cpp \
    src/harbour-sgauth.cpp

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
    qml/pages/MainPage.qml

HEADERS += \
    src/qgoogleauth.h \
    src/hmac.h \
    src/base32.h

RESOURCES += \
    harbour-sgauth.qrc

