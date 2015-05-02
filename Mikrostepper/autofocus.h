#ifndef AUTOFOCUS_H
#define AUTOFOCUS_H

#include <QObject>

#include "camera.h"
#include "stepper.h"

class Autofocus : public QObject
{
	Q_OBJECT
	using zs = double;
	Camera* cam;
	Stepper* navi;
	bool m_stop;
public:
	Autofocus(Camera* cam, Stepper* navi);
	~Autofocus();

public slots:
	void globalSearch();
	void adaptiveSearch();
	void derivativeSearch();
	void scanSearch();
	void slowSearch();

	bool isWorking() const;
	void cancel();

signals:
	void focusFound();
	void focusLost();

private:
	void moveWait(zs target);
	zs initialGuess(zs step = 0.001);
	bool lastCheck(zs step = 0.001);
	void searchGlobal(zs step = 0.001);
	void searchAdaptive();
	void searchDerivative();
	
	void searchScan(double speed = 2.0);
};

#endif // AUTOFOCUS_H
