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
public:
	Autofocus(Camera* cam, Stepper* navi);
	~Autofocus();

public slots:
	void globalSearch();

private:
	void moveWait(zs target);
	zs initialGuess(zs step = 0.001);
	bool lastCheck(zs step = 0.001);
	void searchGlobal(zs step = 0.001);
	void searchAdaptive();
};

#endif // AUTOFOCUS_H
