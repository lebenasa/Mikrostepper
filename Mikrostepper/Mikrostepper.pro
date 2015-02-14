# ----------------------------------------------------
# This file is generated by the Qt Visual Studio Add-in.
# ------------------------------------------------------

TEMPLATE = app
TARGET = Mikrostepper
DESTDIR = ../Win32/Release
QT += core widgets gui qml quick concurrent
CONFIG += release
DEFINES += WIN64 QT_DLL QT_QML_LIB QT_QUICK_LIB QT_CONCURRENT_LIB QT_WIDGETS_LIB
INCLUDEPATH += ./GeneratedFiles \
    . \
    ./GeneratedFiles/Release
PRECOMPILED_HEADER = stdafx.h
DEPENDPATH += .
MOC_DIR += ./GeneratedFiles/release
OBJECTS_DIR += release
UI_DIR += ./GeneratedFiles
RCC_DIR += ./GeneratedFiles
win32:RC_FILE = Mikrostepper.rc
HEADERS += ./tinyxml2.h \
    ./api_wrapper.h \
    ./stdafx.h \
    ./steppernavigator.h \
    ./stepperinterface.h \
    ./stepper.h \
    ./serialcapture.h \
    ./optilabviewer.h \
    ./lebenwindow.h \
    ./cameramodel.h \
    ./cameracontrol.h \
    ./camera.h \
    ./baserecorder.h \
    ./atlascapture.h \
    ./appsettings.h
SOURCES += ./api_wrapper.cpp \
    ./appsettings.cpp \
    ./atlascapture.cpp \
    ./baserecorder.cpp \
    ./camera.cpp \
    ./cameracontrol.cpp \
    ./cameramodel.cpp \
    ./lebenwindow.cpp \
    ./main.cpp \
    ./optilabviewer.cpp \
    ./serialcapture.cpp \
    ./stdafx.cpp \
    ./stepper.cpp \
    ./stepperinterface.cpp \
    ./steppernavigator.cpp \
    ./tinyxml2.cpp
RESOURCES += mikrostepper.qrc