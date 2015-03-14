#ifndef STEPPERNAVIGATOR_H
#define STEPPERNAVIGATOR_H

#include <QObject>

class Stepper;
class StepperNavigator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPointF xy READ xy NOTIFY xyChanged)
    Q_PROPERTY(double z READ z NOTIFY zChanged)
    Q_PROPERTY(QString coordinateString READ coordinateString NOTIFY coordinateStringChanged)
    Q_PROPERTY(double limitXMax READ limitXMax NOTIFY limitXMaxChanged)
    Q_PROPERTY(double limitYMax READ limitYMax NOTIFY limitYMaxChanged)
    Q_PROPERTY(double limitZMax READ limitZMax NOTIFY limitZMaxChanged)
    Q_PROPERTY(double limitXMin READ limitXMin NOTIFY limitXMinChanged)
    Q_PROPERTY(double limitYMin READ limitYMin NOTIFY limitYMinChanged)
    Q_PROPERTY(double limitZMin READ limitZMin NOTIFY limitZMinChanged)
	Q_PROPERTY(int bufferFree READ bufferFree NOTIFY bufferFreeChanged)
	Q_PROPERTY(bool powerOn READ powerOn NOTIFY powerOnChanged)
public:
    explicit StepperNavigator(Stepper *parent);
    ~StepperNavigator();

    double limitXMax() const { return m_limitx.second; }
    double limitYMax() const { return m_limity.second; }
    double limitZMax() const { return m_limitz.second; }
    double limitXMin() const { return m_limitx.first; }
    double limitYMin() const { return m_limity.first; }
    double limitZMin() const { return m_limitz.first; }

    static std::pair<double, double> getLimitX();
    static std::pair<double, double> getLimitY();
	static std::pair<double, double> getLimitZ();

	int bufferFree() const;

	bool powerOn() const;

public slots:
    void initSettings();

    QPointF xy() const;
    double z() const;

    void moveTo(const QPointF& target);
    void moveXY(double x, double y);
    void moveZ(double z);

    void jogXY(int x, int y);
    void jogZ(int z);
    void frameXY(int x, int y);
    void jogSlowXY(int x, int y);
    void jogSlowZ(int z);
	void micronXY(int x, int y);
	void micronZ(int z);

    void stop();

    QString coordinateString();

	void initializeXAx();
	void initializeYAx();

	void zeroXDc();
	void zeroYDc();

signals:
    void limitXMaxChanged(double);
    void limitYMaxChanged(double);
    void limitZMaxChanged(double);
    void limitXMinChanged(double);
    void limitYMinChanged(double);
    void limitZMinChanged(double);

    void bufferFull();
	void bufferFreeChanged(int);

    void xyChanged(const QPointF&);
    void zChanged(const double&);

    void coordinateStringChanged(const QString&);

	void initializeDone();

	void powerOnChanged(bool);

private:
    std::pair<double, double> m_limitx, m_limity, m_limitz, m_speed;
    bool enableLimitX, enableLimitY, enableLimitZ;
    Stepper* stepper;
    QSizeF sz_profile;

	std::pair<bool, bool> switchx, switchy, switchz;

    double adjustx(double);
    double adjusty(double);
    double adjustz(double);
};

#endif // STEPPERNAVIGATOR_H
