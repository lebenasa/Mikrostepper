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
    connect(stepper, &Stepper::bufferFull, this, &StepperNavigator::bufferFull);
    initSettings();
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

    if (x > 0) xbase = 999999;
    else if (x < 0) xbase = -999999;
    if (y > 0) ybase = 999999;
    else if (y < 0) ybase = -999999;

    moveXY(xbase, ybase);
}

void StepperNavigator::jogZ(int z) {
    double zinc = 0;
    if (z > 0) zinc = 999999;
    else if (z < 0) zinc = -999999;
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

void StepperNavigator::stop() {
    stepper->stop();
    stepper->setSpeed(m_speed.second);
}

double StepperNavigator::adjustx(double x) {
    if (!enableLimitX) return x;
    if (x < m_limitx.first) x = m_limitx.first;
    else if (x > m_limitx.second) x = m_limitx.second;
    return x;
}

double StepperNavigator::adjusty(double y) {
    if (!enableLimitY) return y;
    if (y < m_limity.first) y = m_limity.first;
    else if (y > m_limity.second) y = m_limity.second;
    return y;
}

double StepperNavigator::adjustz(double z) {
    if (!enableLimitZ) return z;
    if (z < m_limitz.first) z = m_limitz.first;
    else if (z > m_limitz.second) z = m_limitz.second;
    return z;
}

QString StepperNavigator::coordinateString() {
    QString xyz = "Coordinate in mm: (%1, %2, %3)";
    auto p = xy();
    return xyz.arg(p.x(), 0, 'f', 3).arg(p.y(), 0, 'f', 3).arg(z(), 0, 'f', 3);
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
