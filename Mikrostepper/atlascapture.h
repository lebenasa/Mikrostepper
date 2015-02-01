#ifndef ATLASCAPTURE_H
#define ATLASCAPTURE_H

#include <QObject>

using Command = std::function < void() > ;
using CommandPool = std::queue < Command >;

class StepperNavigator;
class Camera;
class AtlasCapture : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QSize planeSize READ planeSize NOTIFY profileChanged)
    Q_PROPERTY(QPoint currentPos READ currentPos NOTIFY currentPosChanged)
    Q_PROPERTY(QRect captureRect READ captureRect NOTIFY captureRectChanged)
    Q_PROPERTY(QSize approxSize READ approxSize NOTIFY approxSizeChanged)
    Q_PROPERTY(QString approxTime READ approxTime NOTIFY approxTimeChanged)

    QSizeF sz_profile;
    double m_scale;
    double m_overlap;

    std::pair<double, double> m_limitx, m_limity;

    QPoint m_currentPos;
    std::vector<QPoint> v_marks, v_targets;

    StepperNavigator* m_navigator;
    Camera* m_camera;
    int m_progress;
    QRect rc_capture;
    int ct_mark;
    bool pt1ok, pt2ok, pt3ok, pt4ok;

    CommandPool commandPool;
    QString m_saveDir;

    bool checkCoord();
public:
    explicit AtlasCapture(Camera* camera, StepperNavigator *parent = 0);
    ~AtlasCapture();

    QPoint coordToPx(const QPointF& coord);
    QPointF pxToCoord(const QPoint& pixel);

    QSize planeSize();

    QPoint currentPos() const;

    int progress();
    void setProgress(int);

    QRect captureRect() const { return rc_capture; }
    QSize approxSize();
    QString approxTime();

public slots:
    void initSettings();

    void procStepperPos(const QPointF& xy);

    bool setPt1();
    bool setPt2();
    bool setPt3();
    bool setPt4();

    void moveToPixel(int x, int y);
    void startCapture(const QUrl& saveDir);

    void nextCommand();

    void addCommand(Command);
    void addMoveToCommand(const QPointF& target);
    void addBlockCommand(int msecond);
    void addCaptureCommand();
    void flushCommand();

signals:
    void currentPosChanged(const QPoint& xy);
    void profileChanged();
    void progressChanged(int progress);
    void captureRectChanged(const QRect caprect);
    void approxSizeChanged();
    void approxTimeChanged();
};

#endif // ATLASCAPTURE_H
