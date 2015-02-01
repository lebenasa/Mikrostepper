#include "stdafx.h"
#include "stepper.h"
#include "appsettings.h"

//#include "api_wrapper.h"

//Stepper
Stepper::Stepper(QObject *parent)
    : QObject(parent)
{
}

Stepper::~Stepper()
{
}

void Stepper::setSpeed(double spd) {
    m_speed = spd;
}

// MockStepper
MockStepper::MockStepper(QObject* parent)
    : Stepper(parent), m_z(0), m_bufferSize(14),
      m_bufferFree(14), m_ztarget(0)
{
    m_limit = std::bitset<8>(false);
    eventDriver = new QTimer(this);
    eventDriver->setInterval(1);
    connect(eventDriver, &QTimer::timeout, this, &MockStepper::updateStatus);
    eventDriver->start();
    m_available = true;
}

MockStepper::~MockStepper() {
}

void MockStepper::setBufferFree(int val) {
    if (m_bufferFree != val) {
        m_bufferFree = val;
        emit bufferFreeChanged(val);
    }
}

void MockStepper::updateStatus() {
    auto incr = [](const double &now, const double &target) -> double {
        double res = now;
        if (target > now)
            return res + .05;
        return res - .05;
    };
    if (m_target != m_pos) {
        if (m_target.x() != m_pos.x()) {
            auto npos = incr(m_pos.x(), m_target.x());
            m_pos.setX(npos);
            emit xChanged(npos);
        }
        if (m_target.y() != m_pos.y()) {
            auto npos = incr(m_pos.y(), m_target.y());
            m_pos.setY(npos);
            emit yChanged(npos);
        }
        emit xyChanged(m_pos);

        if (fabs(m_pos.x() - m_target.x()) <= .1 &&
                fabs(m_pos.y() - m_target.y()) <= .1) {
            stop();
            if (m_bufferFree == m_bufferSize)
                emit bufferFull();
        }
    }
    if (m_ztarget != m_z) {
        auto npos = incr(m_z, m_ztarget);
        m_z = npos;
        emit zChanged(npos);
    }
}

void MockStepper::setTarget(const QPointF& ntarget) {
    eventDriver->stop();
    m_target = ntarget;
    setBufferFree(bufferFree() - 1);
    eventDriver->start();
}

void MockStepper::setTarget(double x, double y) {
    double xx, yy;
    xx = (x < 0) ? m_pos.x() : x;
    yy = (y < 0) ? m_pos.y() : y;
    setTarget(QPointF(xx, yy));
}

void MockStepper::stop() {
    eventDriver->stop();
    m_target = m_pos;
    setBufferFree(bufferSize());
    emit xChanged(m_pos.x());
    emit yChanged(m_pos.y());
    emit xyChanged(m_pos);
}

void MockStepper::moveX(double dist) {
    if (bufferFree() == bufferSize()) {
        setTarget(m_pos.x() + dist, -1);
    }
}

void MockStepper::moveY(double dist) {
    if (bufferFree() == bufferSize()) {
        setTarget(-1, m_pos.y() + dist);
    }
}

void MockStepper::moveZ(double dist) {
    if (bufferFree() == bufferSize()) {
        m_ztarget = m_z + dist;
    }
}

void MockStepper::moveTo(const QPointF& npos) {
    if (bufferFree() == bufferSize()) {
        setTarget(npos);
    }
}

void MockStepper::setZeroX() {
    m_pos.setX(0.0);
    updateStatus();
}

void MockStepper::setZeroY() {
    m_pos.setY(0.0);
    updateStatus();
}

void MockStepper::setZeroZ() {
    m_z = 0.0;
    updateStatus();
}
