#include "stdafx.h"
#include "stepperinterface.h"
#include "appsettings.h"
#include "steppernavigator.h"

StepperInterface::StepperInterface(QObject *parent)
    : QObject(parent), m_overlap(0.25), pt_tlo(0, 0)
{
    AppSettings s;
    int colct = s.readInt("GridCol", 13);
    int rowct = s.readInt("GridRow", 13);
    setDims(QSize(colct, rowct));
    initSettings();
}

StepperInterface::~StepperInterface()
{
}

QPoint StepperInterface::coordToIndex(const QPointF& pos) const {
    return xytomn(pos) - pt_tlo;
}

QPointF StepperInterface::indexToCoord(const QPoint &pos) const {
    return mntoxy(pos + pt_tlo);
}

QPoint StepperInterface::xytomn(const QPointF& pos) const {
    int m = round((pos.x() - m_limitx.first) / sz_profile.width());
    int n = round((pos.y() - m_limity.first) / sz_profile.height());
    if (m < 0) m = 0;
    if (n < 0) n = 0;
    auto maxsz = maxSize();
    if (m > maxsz.width()) m = maxsz.width();
    if (n > maxsz.height()) n = maxsz.height();
    return QPoint(m, n);
}

QPointF StepperInterface::mntoxy(const QPoint &pos) const {
    double x = 1.0 * pos.x() * sz_profile.width() + m_limitx.first;
    double y = 1.0 * pos.y() * sz_profile.height() + m_limity.first;
    return QPointF(x, y);
}

QSize StepperInterface::maxSize() const {
    int maxcol = floor((m_limitx.second - m_limitx.first) / sz_profile.width());
    int maxrow = floor((m_limity.second - m_limity.first) / sz_profile.height());
    return QSize(maxcol, maxrow);
}

QSize StepperInterface::setTLOffset(const QPointF &newoffset) {
    auto ntlo = xytomn(newoffset);
    int sw = ntlo.x() - pt_tlo.x();
    int sh = ntlo.y() - pt_tlo.y();
    if (sw > sz_cell.width() || sh > sz_cell.height() ||
            sw < 0 || sh < 0) {
        pt_tlo = ntlo;
        return QSize(sw, sh);
    }
    return QSize(0, 0);
}

QSize StepperInterface::setCenter(const QPointF &center) {
    int ox = sz_cell.width() / 2;
    int cx = center.x();
    int oy = sz_cell.height() / 2;
    int cy = center.y();

    auto ml = cx + 1.0 * ox * sz_profile.width();
    if (ml > m_limitx.second) cx -= ml - m_limitx.second;
    auto nl = cy + 1.0 * oy * sz_profile.height();
    if (nl > m_limity.second) cy -= nl - m_limity.second;

    auto mo = cx - 1.0 * ox * sz_profile.width();
    if (mo < m_limitx.first) mo = m_limitx.first;
    auto no = cy - 1.0 * oy * sz_profile.height();
    if (no < m_limity.first) no = m_limity.first;
    return setTLOffset(QPointF(mo, no));
}

QSize StepperInterface::setTopLeft(const QPointF &topleft) {
    auto tl_index = xytomn(topleft);
    auto maxsz = maxSize();
    int maxcol = maxsz.width() - sz_cell.width();
    int maxrow = maxsz.height() - sz_cell.height();

    if (tl_index.x() > maxcol) tl_index.setX(maxcol);
    if (tl_index.y() > maxrow) tl_index.setY(maxrow);

    int sw = tl_index.x() - pt_tlo.x();
    int sh = tl_index.y() - pt_tlo.y();

    pt_tlo = tl_index;
    return QSize(sw, sh);
}

QSize StepperInterface::shiftOffset(const QSize &shift) {
    auto szmax = maxSize();
    int maxcol = szmax.width() - sz_cell.width();
    int maxrow = szmax.height() - sz_cell.height();
    int cx = pt_tlo.x();
    int cy = pt_tlo.y();
    int sw = shift.width();
    int sh = shift.height();

    if (cx < maxcol && sw > 0) pt_tlo.setX(cx + sw);
    if (cx > 0 && sw < 0) pt_tlo.setX(cx + sw);
    if (cy < maxrow && sh > 0) pt_tlo.setY(cy + sh);
    if (cy > 0 && sh < 0) pt_tlo.setY(cy + sh);

    return QSize(pt_tlo.x() - cx, pt_tlo.y() - cy);
}

void StepperInterface::initSettings() {
    AppSettings s(this);
    QSizeF sz = QSizeF(s.readProfileWidth(s.getActiveProfileId()), s.readProfileHeight(s.getActiveProfileId()));

    sz_profile = QSizeF((1.0 - m_overlap) * sz.width() / 1000.0,
                        (1.0 - m_overlap) * sz.height() / 1000.0);

    m_limitx = StepperNavigator::getLimitX();
    m_limity = StepperNavigator::getLimitY();

    emit profileChanged();
}

void StepperInterface::setOverlap(double &ovl) {
    if (m_overlap != ovl) {
        m_overlap = ovl;
        initSettings();
    }
}

void StepperInterface::setDims(const QSize &side) {
    if (sz_cell != side) {
        sz_cell = side;
        emit cellDimsChanged(sz_cell);
    }
}
