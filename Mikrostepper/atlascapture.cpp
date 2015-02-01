#include "stdafx.h"
#include "atlascapture.h"

#include "camera.h"
#include "appsettings.h"
#include "steppernavigator.h"
using namespace std;

AtlasCapture::AtlasCapture(Camera *camera, StepperNavigator *parent)
    : QObject(parent), m_camera(camera), m_navigator(parent),
      m_scale(0.01), m_overlap(0.25), v_marks(4), ct_mark(0)
{
    setProgress(0);
    pt1ok = pt2ok = pt3ok = pt4ok = false;
    connect(m_navigator, &StepperNavigator::xyChanged, this, &AtlasCapture::procStepperPos);
    initSettings();
}

AtlasCapture::~AtlasCapture()
{

}

void AtlasCapture::initSettings() {
    AppSettings s(this);
    QSizeF sz = QSizeF(s.readProfileWidth(s.getActiveProfileId()), s.readProfileHeight(s.getActiveProfileId()));

    sz_profile = QSizeF((1.0 - m_overlap) * sz.width() / 1000.0,
                        (1.0 - m_overlap) * sz.height() / 1000.0);

    m_limitx = StepperNavigator::getLimitX();
    m_limity = StepperNavigator::getLimitY();

    m_scale = s.readDouble("MapScale", 0.01);

    emit approxSizeChanged();
    emit approxTimeChanged();
    emit profileChanged();
}

QPoint AtlasCapture::coordToPx(const QPointF &coord) {
    auto adjusted = coord - QPointF(m_limitx.first, m_limity.first);
    if (adjusted.x() < 0) adjusted.setX(0);
    if (adjusted.y() < 0) adjusted.setY(0);
    if (adjusted.x() > m_limitx.second - m_limitx.first) adjusted.setX(m_limitx.second - m_limitx.first);
    if (adjusted.y() > m_limity.second - m_limity.first) adjusted.setY(m_limity.second - m_limity.first);
    return (adjusted * 1000.0 * m_scale).toPoint();
}

QPointF AtlasCapture::pxToCoord(const QPoint &pixel) {
    return QPointF(1.0 * pixel.x() / (1000.0 * m_scale), 1.0 * pixel.y() / (1000.0 * m_scale)) +
            QPointF(m_limitx.first, m_limity.first);
}

QSize AtlasCapture::planeSize() {
    QSizeF sz_limit = QSizeF(m_limitx.second - m_limitx.first, m_limity.second - m_limity.first);
    return (sz_limit * 1000.0 * m_scale).toSize();
}

int AtlasCapture::progress() {
    return m_progress;
}

void AtlasCapture::setProgress(int pg) {
    m_progress = pg;
    emit progressChanged(pg);
}

void AtlasCapture::procStepperPos(const QPointF &xy) {
    if (m_currentPos != coordToPx(xy)) {
        m_currentPos = coordToPx(xy);
        emit currentPosChanged(m_currentPos);
    }
}

QPoint AtlasCapture::currentPos() const {
    return m_currentPos;
}

void AtlasCapture::startCapture(const QUrl& saveDir) {
    QPointF tl = pxToCoord(rc_capture.topLeft());
    QSize ct = approxSize();
    int x = 0;
    v_targets.clear();
    vector<QPointF> targets;
    for (int y = 0; y < ct.height(); ++y) {
        for (int i = 0; i < ct.width(); ++i) {
            v_targets.push_back(QPoint(x, y));
            x = (y%2 == 0) ? x + 1 : x - 1;
        }
        x = (y%2 == 0) ? x - 1 : x + 1;
    }
    for (size_t i = 0; i < v_targets.size(); ++i) {
        targets.push_back(tl + (QPointF(1.0 * v_targets.at(i).x() * sz_profile.width(),
                                   1.0 * v_targets.at(i).y() * sz_profile.height())));
    }
    setProgress(0);
    m_saveDir = saveDir.toLocalFile();
    for (auto target : targets) {
        addMoveToCommand(target);
        addBlockCommand(250);
        addCaptureCommand();
        addBlockCommand(250);
    }
    nextCommand();
}

void AtlasCapture::addCommand(Command cmd) {
    commandPool.push(cmd);
}

void AtlasCapture::addMoveToCommand(const QPointF &target) {
    addCommand([=]() {
        connect(m_navigator, &StepperNavigator::bufferFull, this, &AtlasCapture::nextCommand);
        m_navigator->moveTo(target);
    });
}

void AtlasCapture::addBlockCommand(int msecond) {
    auto cmd = [=]() {
        QTimer::singleShot(msecond, this, SLOT(nextCommand()));
    };
    addCommand(cmd);
}

void AtlasCapture::addCaptureCommand() {
    auto cmd = [=]() {
        QPoint pt = v_targets.at(m_progress);
        auto base = m_saveDir;
        auto fn = base + "/" + QString("%1_%2.jpg").arg(pt.y(), 4, 10, QChar('0')).
                arg(pt.x(), 4, 10, QChar('0'));
        m_camera->capture(1, fn);
        setProgress(m_progress + 1);
        QTimer::singleShot(100, this, SLOT(nextCommand()));
    };
    addCommand(cmd);
}

void AtlasCapture::nextCommand() {
    disconnect(m_navigator, &StepperNavigator::bufferFull, this, &AtlasCapture::nextCommand);
    if (!commandPool.empty()) {
        auto cmd = commandPool.front();
        cmd();
        commandPool.pop();
    }
}

void AtlasCapture::flushCommand() {
    disconnect(m_navigator, &StepperNavigator::bufferFull, this, &AtlasCapture::nextCommand);
    m_navigator->stop();
    while (!commandPool.empty())
        commandPool.pop();
}

QRect enclosedRect(vector<QPoint> marks) {
    vector<int> x,y;
    for (auto mark: marks) {
        if (mark.isNull()) continue;
        x.push_back(mark.x());
        y.push_back(mark.y());
    }
    sort(begin(x), end(x));
    sort(begin(y), end(y));
    QPoint tl (*begin(x), *begin(y));
    QPoint br (*(end(x)-1), *(end(y)-1));
    return QRect(tl, br);
}

bool AtlasCapture::checkCoord() {
    auto cp = m_navigator->xy();
    if (cp.x() < m_limitx.first || cp.x() > m_limitx.second ||
            cp.y() < m_limity.first || cp.y() > m_limity.second)
        return false;
    return true;
}

bool AtlasCapture::setPt1() {
    if (!checkCoord())
        return false;
    v_marks[0] = currentPos();
    if (!pt1ok) {
        pt1ok = true;
        ++ct_mark;
    }
    if (ct_mark > 1) {
        rc_capture = enclosedRect(v_marks);
        emit captureRectChanged(rc_capture);
        emit approxSizeChanged();
        emit approxTimeChanged();
    }
    return true;
}

bool AtlasCapture::setPt2() {
    if (!checkCoord())
        return false;
    v_marks[1] = currentPos();
    if (!pt2ok) {
        pt2ok = true;
        ++ct_mark;
    }
    if (ct_mark > 1) {
        rc_capture = enclosedRect(v_marks);
        emit captureRectChanged(rc_capture);
        emit approxSizeChanged();
        emit approxTimeChanged();
    }
    return true;
}

bool AtlasCapture::setPt3() {
    if (!checkCoord())
        return false;
    v_marks[2] = currentPos();
    if (!pt3ok) {
        pt3ok = true;
        ++ct_mark;
    }
    if (ct_mark > 1) {
        rc_capture = enclosedRect(v_marks);
        emit captureRectChanged(rc_capture);
        emit approxSizeChanged();
        emit approxTimeChanged();
    }
    return true;
}

bool AtlasCapture::setPt4() {
    if (!checkCoord())
        return false;
    v_marks[3] = currentPos();
    if (!pt4ok) {
        pt4ok = true;
        ++ct_mark;
    }
    if (ct_mark > 1) {
        rc_capture = enclosedRect(v_marks);
        emit captureRectChanged(rc_capture);
        emit approxSizeChanged();
        emit approxTimeChanged();
    }
    return true;
}

QSize AtlasCapture::approxSize() {
    int ctx = ceil(1.0 * rc_capture.width() / (1000.0 * m_scale * sz_profile.width())) + 1;
    int cty = ceil(1.0 * rc_capture.height() / (1000.0 * m_scale * sz_profile.height())) + 1;
    return QSize(ctx, cty);
}

QString AtlasCapture::approxTime() {
    auto sz = approxSize();
    int frames = sz.width() * sz.height();
    int secs = frames * 2;
    int min = secs / 60;
    int hr = min / 60;
    QString text;
    if (hr > 0) {
        text += QString("%1 hour(s) ").arg(hr);
        min -= 60 * hr;
    }
    if (min > 0) {
        text += QString("%1 minute(s) ").arg(min);
        secs -= (3600 * hr) + (60 * min);
    }
    text += QString("%1 seconds ").arg(secs);
    return text;
}

void AtlasCapture::moveToPixel(int x, int y) {
    m_navigator->moveTo(pxToCoord(QPoint(x, y)));
}
