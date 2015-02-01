#ifndef CAMERACONTROL_H
#define CAMERACONTROL_H

#include <QObject>

class CameraControl : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double rGain READ rGain WRITE setRGain NOTIFY rGainChanged)
    Q_PROPERTY(double gGain READ gGain WRITE setGGain NOTIFY gGainChanged)
    Q_PROPERTY(double bGain READ bGain WRITE setBGain NOTIFY bGainChanged)
    Q_PROPERTY(double gamma READ gamma  WRITE setGamma  NOTIFY gammaChanged)
    Q_PROPERTY(double contrast READ contrast  WRITE setContrast  NOTIFY contrastChanged)
    Q_PROPERTY(double saturation READ saturation WRITE setSaturation NOTIFY saturationChanged)
    Q_PROPERTY(bool autoexposure READ autoexposure WRITE setAutoexposure NOTIFY autoexposureChanged)
    Q_PROPERTY(double aeGain READ aeGain WRITE setAeGain NOTIFY aeGainChanged)
    Q_PROPERTY(double exposureTime READ exposureTime WRITE setExposureTime NOTIFY exposureTimeChanged)
    Q_PROPERTY(double aeTarget READ aeTarget WRITE setAeTarget NOTIFY aeTargetChanged)
public:
    explicit CameraControl(QObject *parent = 0);
    ~CameraControl();

signals:
    void rGainChanged(double);
    void gGainChanged(double);
    void bGainChanged(double);
    void gammaChanged(double);
    void contrastChanged(double);
    void saturationChanged(double);
    void autoexposureChanged(bool);
    void aeGainChanged(double);
    void exposureTimeChanged(double);
    void aeTargetChanged(double);

public slots:
    void oneShotWB();

	double rGain() const;
	void setRGain(double val);
	double gGain() const;
	void setGGain(double val);
	double bGain() const;
	void setBGain(double val);

	double gamma() const;
	void setGamma(double val);
	double contrast() const;
	void setContrast(double val);
	double saturation() const;
	void setSaturation(double val);

	bool autoexposure() const;
	void setAutoexposure(bool);
	double aeGain() const;
	void setAeGain(double val);
	double exposureTime() const;
	void setExposureTime(double);
	double aeTarget() const;
	void setAeTarget(double);
    double maxExposureTime();

    void saveParametersA();
    void loadParametersA();
    void saveParametersB();
    void loadParametersB();
    void saveParametersC();
    void loadParametersC();
    void saveParametersD();
    void loadParametersD();

    void loadDefaultParameters();

	void reloadParams();

	int getCurrentParameterTeam();

private:
    double _rg, _gg, _bg, _gamma, _contrast, _saturation, _aegain, _aetarget, _exptime;
    bool _ae;
};

#endif // CAMERACONTROL_H
