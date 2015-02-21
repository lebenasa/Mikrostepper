#include "stdafx.h"
#include "steppernavigator.h"
#include "stepper.h"
#include "appsettings.h"

StepperNavigator::StepperNavigator(Stepper *parent)
    : QObject(parent), stepper(parent)
{
    connect(stepper, &Stepper::xChanged, [this](double x) { emit xyChanged(QPointF(x, stepper->y()));});
    connect(stepper, &Stepper::yChanged, [this](double y) { emit xyChanged(QPointF(stepper->x(), y));});
    connect(stepper, &Stepper::zChanged, this, &StepperNavigator::zChanged);
    connect(this, &StepperNavigator::xyChanged, [this]() { emit coordinateStringChanged(coordinateString());});
    connect(this, &StepperNavigator::zChanged, [this]() { emit coordinateStringChanged(coordinateString());});
	connect(stepper, &Stepper::bufferFreeChanged, [this]() { emit coordinateStringChanged(coordinateString());});
    connect(stepper, &Stepper::bufferFull, this, &StepperNavigator::bufferFull);
    initSettings();
	switchx = { false, false };
	switchy = { false, false };
	switchz = { false, false };
}

StepperNavigator::~StepperNavigator()
{

}

void StepperNavigator::initSettings() {
    AppSettings s;
    m_limitx.first = s.readDouble("LimitXMin", 0.0);
    m_limitx.second = s.readDouble("LimitXMax", 150.0);
    m_limity.first = s.readDouble("LimitYMin", 0.0);
    m_limity.second = s.readDouble("LimitYMax", 100.0);
    m_limitz.first = s.readDouble("LimitZMin", 0.0);
    m_limitz.second = s.readDouble("LimitZMax", 100.0);
    m_speed.first = s.readDouble("SpeedLo", 10.0);
    m_speed.second = s.readDouble("SpeedHi", 100.0);
    emit limitXMinChanged(m_limitx.first );
    emit limitXMaxChanged(m_limitx.second);
    emit limitYMinChanged(m_limity.first);
    emit limitYMaxChanged(m_limity.second);
    emit limitZMinChanged(m_limitz.first);
    emit limitZMaxChanged(m_limitz.second);

    QSizeF sz = QSizeF(s.readProfileWidth(s.getActiveProfileId()), s.readProfileHeight(s.getActiveProfileId()));

    sz_profile = QSizeF(1.0 * sz.width() / 1000.0, 1.0 * sz.height() / 1000.0);

    enableLimitX = s.readBool("EnableLimitX", true);
    enableLimitY = s.readBool("EnableLimitY", true);
    enableLimitZ = s.readBool("EnableLimitZ", true);

	bool swt = s.readBool("StopOnMinX", true);
	if (swt) {
		if (stepper->limit0()) switchx.first = true;
		connect(stepper, &Stepper::limit0Changed, [this](bool v){ if (v) stop(); switchx.first = v; });
	}
	else disconnect(stepper, SIGNAL(limit0Changed()), 0, 0);
	swt = s.readBool("StopOnMaxX", true);
	if (swt) {
		if (stepper->limit1()) switchx.second = true;
		connect(stepper, &Stepper::limit1Changed, [this](bool v){ if (v) stop(); switchx.second = v; });
	}
	else disconnect(stepper, SIGNAL(limit1Changed()), 0, 0);
	swt = s.readBool("StopOnMinY", true);
	if (swt) {
		if (stepper->limit2()) switchy.first = true;
		connect(stepper, &Stepper::limit2Changed, [this](bool v){ if (v) stop(); switchy.first = v; });
	}
	else disconnect(stepper, SIGNAL(limit2Changed()), 0, 0);
	swt = s.readBool("StopOnMaxY", true);
	if (swt) {
		if (stepper->limit3()) switchy.second = true;
		connect(stepper, &Stepper::limit3Changed, [this](bool v){ if (v) stop(); switchy.second = v; });
	}
	else disconnect(stepper, SIGNAL(limit3Changed()), 0, 0);
	swt = s.readBool("StopOnMinZ", true);
	if (swt) {
		if (stepper->limit4()) switchz.first = true;
		connect(stepper, &Stepper::limit4Changed, [this](bool v){ if (v) stop(); switchz.first = v; });
	}
	else disconnect(stepper, SIGNAL(limit4Changed()), 0, 0);
	swt = s.readBool("StopOnMaxZ", true);
	if (swt) {
		if (stepper->limit5()) switchz.second = true;
		connect(stepper, &Stepper::limit5Changed, [this](bool v){ if (v) stop(); switchz.second = v; });
	}
	else disconnect(stepper, SIGNAL(limit5Changed()), 0, 0);
}

QPointF StepperNavigator::xy() const {
    return QPointF(stepper->x(), stepper->y());
}

double StepperNavigator::z() const {
    return stepper->z();
}

void StepperNavigator::moveTo(const QPointF &target) {
    moveXY(target.x(), target.y());
}

void StepperNavigator::moveXY(double x, double y) {
    stepper->moveTo(QPointF(adjustx(x), adjusty(y)));
}

void StepperNavigator::moveZ(double z) {
    stepper->moveZ(adjustz(z));
}

void StepperNavigator::jogXY(int x, int y) {
    auto xbase = stepper->x();
    auto ybase = stepper->y();

    if (x > 0) xbase = 9999;
    else if (x < 0) xbase = -9999;
    if (y > 0) ybase = 9999;
    else if (y < 0) ybase = -9999;

    moveXY(xbase, ybase);
}

void StepperNavigator::jogZ(int z) {
    double zinc = 0;
    if (z > 0) zinc = 9999;
    else if (z < 0) zinc = -9999;
    moveZ(zinc);
}

void StepperNavigator::frameXY(int x, int y) {
    auto xbase = stepper->x();
    auto ybase = stepper->y();
    double xinc, yinc;
    xinc = 0;
    if (x > 0) xinc = sz_profile.width();
    else if (x < 0) xinc = -sz_profile.width();
    yinc = 0;
    if (y > 0) yinc = sz_profile.height();
    else if (y < 0) yinc = -sz_profile.height();
    moveXY(xbase + xinc, ybase + yinc);
}

void StepperNavigator::jogSlowXY(int x, int y) {
    stepper->setSpeed(m_speed.first);
    jogXY(x, y);
}

void StepperNavigator::jogSlowZ(int z) {
    stepper->setSpeed(m_speed.first);
    jogZ(z);
}

void StepperNavigator::micronXY(int x, int y) {
	auto xbase = stepper->x();
	auto ybase = stepper->y();
	double xinc, yinc;
	xinc = 0;
	if (x > 0) xinc = 0.001;
	else if (x < 0) xinc = -0.001;
	yinc = 0;
	if (y > 0) yinc = 0.001;
	else if (y < 0) yinc = -0.001;
	moveXY(xbase + xinc, ybase + yinc);
}

void StepperNavigator::micronZ(int z) {
	auto zbase = stepper->z();
	double zinc = 0;
	if (z > 0) zinc = 0.001;
	else if (z < 0) zinc = -0.001;
	moveZ(zbase + zinc);
}

void StepperNavigator::stop() {
    stepper->stop();
    stepper->setSpeed(m_speed.second);
}

double StepperNavigator::adjustx(double x) {
	auto currentX = xy().x();
	if (x > currentX && switchx.second) return currentX;
	else if (x < currentX && switchx.first) return currentX;

    if (!enableLimitX) return x;
    if (x < m_limitx.first) x = m_limitx.first;
    else if (x > m_limitx.second) x = m_limitx.second;
    return x;
}

double StepperNavigator::adjusty(double y) {
	auto currentY = xy().y();
	if (y > currentY && switchy.second) return currentY;
	else if (y < currentY && switchy.first) return currentY;

    if (!enableLimitY) return y;
    if (y < m_limity.first) y = m_limity.first;
    else if (y > m_limity.second) y = m_limity.second;
    return y;
}

double StepperNavigator::adjustz(double z) {
	auto currentZ = this->z();
	if (z > currentZ && switchz.second) return currentZ;
	else if (z < currentZ && switchz.first) return currentZ;

    if (!enableLimitZ) return z;
    if (z < m_limitz.first) z = m_limitz.first;
    else if (z > m_limitz.second) z = m_limitz.second;
    return z;
}

QString StepperNavigator::coordinateString() {
    QString xyz = "Coordinate in mm: (%1, %2, %3)";
    auto p = xy();
	//auto bf = stepper->bufferFree();
    return xyz.arg(p.x(), 0, 'f', 3).arg(p.y(), 0, 'f', 3).arg(z(), 0, 'f', 3)/*.arg(bf)*/;
}

std::pair<double, double> StepperNavigator::getLimitX() {
    AppSettings s;
    auto min = s.readDouble("LimitXMin", 0.0);
    auto max = s.readDouble("LimitXMax", 150.0);
    return std::pair<double, double> {min, max};
}

std::pair<double, double> StepperNavigator::getLimitY() {
    AppSettings s;
    auto min = s.readDouble("LimitYMin", 0.0);
    auto max = s.readDouble("LimitYMax", 150.0);
    return std::pair<double, double> {min, max};
}

std::pair<double, double> StepperNavigator::getLimitZ() {
    AppSettings s;
    auto min = s.readDouble("LimitZMin", 0.0);
    auto max = s.readDouble("LimitZMax", 150.0);
    return std::pair<double, double> {min, max};
}

void StepperNavigator::initializeXAx() {
	if (switchx.first) {
		zeroXDc();
		return;
	}
	enableLimitX = false;
	connect(stepper, &Stepper::limit0Changed, [this](bool v){ if (v) stop(); switchx.first = v; });
	connect(this, &StepperNavigator::bufferFull, this, &StepperNavigator::zeroXDc, Qt::UniqueConnection);
	jogXY(-1, 0);
}

void StepperNavigator::initializeYAx() {
	if (switchy.first) {
		zeroYDc();
		return;
	}
	enableLimitY = false;
	connect(stepper, &Stepper::limit2Changed, [this](bool v){ if (v) stop(); switchy.first = v; });
	connect(this, &StepperNavigator::bufferFull, this, &StepperNavigator::zeroYDc, Qt::UniqueConnection);
	jogXY(0, -1);
}

void StepperNavigator::zeroXDc() {
	stepper->setZeroX();
	disconnect(this, &StepperNavigator::bufferFull, this, &StepperNavigator::zeroXDc);
	initSettings();
	emit initializeDone();
}

void StepperNavigator::zeroYDc() {
	stepper->setZeroY();
	disconnect(this, &StepperNavigator::bufferFull, this, &StepperNavigator::zeroYDc);
	initSettings();
	emit initializeDone();
}