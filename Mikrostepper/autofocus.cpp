#include "stdafx.h"
#include "autofocus.h"

#include <thread>
#include <future>

using namespace std;
using namespace std::chrono;

Autofocus::Autofocus(Camera* c, Stepper* n)
	: QObject(c), cam(c), navi(n)
{

}

Autofocus::~Autofocus()
{

}

void Autofocus::moveWait(double target) {
	navi->moveToZ(target);
	this_thread::sleep_for(milliseconds{ 300 });
	while (navi->bufferFree() != navi->bufferSize())
		this_thread::sleep_for(milliseconds{ 10 });
}

double Autofocus::initialGuess(double step) {
	zs ipos = navi->z();
	double ival = cam->focusValue();
	moveWait(ipos + step);
	double upval = cam->focusValue();
	moveWait(ipos);
	if (upval > ival) return step;
	return -step;
}

bool Autofocus::lastCheck(double step) {
	if (step > 0)
		return (initialGuess(step) > 0) ? true : false;
	return (initialGuess(step) > 0) ? false : true;
}

void Autofocus::searchGlobal(double step) {
	zs iguess = initialGuess(step);
	double ival = cam->focusValue();
	double nval = ival;
	auto itime = steady_clock::now();
	auto mv = (iguess > 0) ? step : -step;
	do {
		ival = nval;
		moveWait(navi->z() + mv);
		nval = cam->focusValue();
		auto dtime = steady_clock::now() - itime;
		if (duration_cast<seconds>(dtime).count() > 3)
			break;
	} while (nval > ival);
	if (lastCheck(mv)) searchGlobal(step);
}

void Autofocus::searchAdaptive() {
	zs iguess = initialGuess(0.016);

}

void Autofocus::globalSearch() {
	async(launch::async, [this]() { searchGlobal(0.001); });
}