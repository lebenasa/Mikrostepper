#include "stdafx.h"
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "lebenwindow.h"

#include "camera.h"
#include "stepper.h"
#include "serialcapture.h"
#include "optilabviewer.h"
#include "atlascapture.h"
#include "appsettings.h"
#include "steppernavigator.h"
#include "cameracontrol.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
	qmlRegisterType<LebenWindow>("Leben.Asa", 1, 0, "LebenWindow");
	qmlRegisterType<QuickCam>("QuickCam", 1, 0, "CameraItem");

    AppSettings settings;
	settings.updateCNCSettings();
    MockCamera camera;
	if (!camera.isAvailable()) {
		return 0;
	}
    MockStepper stepper(&camera);
	if (!stepper.isAvailable()) {
		return 0;
	}

    CameraControl camctr(&camera);
    StepperNavigator nav(&stepper);
    OptilabViewer ov(&camera);
    SerialCapture sc(&camera, &nav, &camera);
    AtlasCapture ac(&camera, &nav);
    QQmlApplicationEngine engine(&camera);
    auto ctx = engine.rootContext();
    ctx->setContextProperty("appsettings", &settings);
    ctx->setContextProperty("camera", &camera);
    ctx->setContextProperty("stepper", &stepper);
    ctx->setContextProperty("navigator", &nav);
    ctx->setContextProperty("optilab", &ov);
    ctx->setContextProperty("atlas", &ac);
    ctx->setContextProperty("camprop", &camctr);
    sc.setQmlContext(ctx);

    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    return app.exec();
}
