#ifndef STEPPERINTERFACE_H
#define STEPPERINTERFACE_H

#include <QObject>

class StepperInterface : public QObject
{
    Q_OBJECT
public:
    StepperInterface(QObject *parent = 0);
    ~StepperInterface();

    QSize cellDims() const { return sz_cell; }
    void setDims(const QSize& side);

    QPoint coordToIndex(const QPointF& pos) const;
    QPointF indexToCoord(const QPoint& pos) const;

    QSize setCenter(const QPointF& center);
    QSize setTopLeft(const QPointF& topleft);

    QSize shiftOffset(const QSize& shift);

signals:
    void profileChanged();
    void cellDimsChanged(const QSize& dims);

public slots:
    void setOverlap(double& ovl);
    double overlap() const { return m_overlap; }

    void initSettings();

private:
    double m_overlap;
    QSizeF sz_profile;
    QSize sz_cell;
    QPoint pt_tlo;

    std::pair<double, double> m_limitx, m_limity;

    QPoint xytomn(const QPointF& pos) const;
    QPointF mntoxy(const QPoint& pos) const;
    QSize setTLOffset(const QPointF& newoffset);

    QSize maxSize() const;
};

#endif // STEPPERINTERFACE_H
