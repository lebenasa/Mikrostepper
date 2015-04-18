#include "stdafx.h"
#include "autofocus.h"

#include <functional>
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
	ipos = navi->z();
	ival = cam->focusValue();
	moveWait(ipos - step);
	upval = cam->focusValue();
	moveWait(ipos);
	if (upval > ival) return -step;
	return 0.0;
}

bool Autofocus::lastCheck(double step) {
	if (step > 0) {
		auto guess = initialGuess(step);
		if (guess > 0.0)
			return true;
		moveWait(navi->z() - step);
		return false;
	}
	auto guess = initialGuess(step);
	if (guess > 0.0) {
		moveWait(navi->z() + step);
		return false;
	}
	return true;
}

void Autofocus::searchGlobal(double step) {
	zs iguess = initialGuess(step);
	if (iguess == 0.0) return;
	double ival = cam->focusValue();
	double nval = ival;
	auto itime = steady_clock::now();
	auto mv = (iguess > 0) ? step : -step;
	do {
		moveWait(navi->z() + mv);
		ival = nval;
		nval = cam->focusValue();
		cout << nval << "\n";
		auto dtime = steady_clock::now() - itime;
		if (duration_cast<seconds>(dtime).count() > 3)
			break;
	} while (nval > ival);
	if (lastCheck(mv)) searchGlobal(step);
}

void Autofocus::searchAdaptive() {
	zs iguess = initialGuess(0.05);
	zs z0 = navi->z();
	double ival = cam->focusValue();
	moveWait(z0 + iguess);
	zs z1 = navi->z();
	double nval = cam->focusValue();
	auto ratio = [](double f1, double f2) { return (f2 - f1) / f2; };
	auto nz = [](zs now, zs prev, double ratio) { return now + (0.5 * (now - prev) / ratio); };
	//auto itime = steady_clock::now();
	double crat = 0.0;
	do {
		crat = ratio(ival, nval);
		auto z2 = nz(z1, z0, crat);
		moveWait(z2);
		ival = nval;
		nval = cam->focusValue();
		z0 = z1;
		z1 = navi->z();
		//auto dtime = steady_clock::now() - itime;
		//if (duration_cast<seconds>(dtime).count() > 3)
		//	break;
		cout << z2 << "\n";
	} while (crat > 0.0);
	//if (lastCheck(nz(z1, z0, crat))) searchAdaptive();

	//searchGlobal();
}

void Autofocus::searchDerivative() {
	zs h = initialGuess(0.005);
	zs ig = h;
	zs zo = navi->z();
	double fo = cam->focusValue();
	moveWait(zo + h);
	zs zi = navi->z();
	double fi = cam->focusValue();
	cout << h << "\n";

	auto ratio = [](double fo, double fi) { return (fi - fo) / fi; };
	auto nh = [](double h, double ratio) { return (1.0 / ratio > 1.25) ? 1.25*h : h / ratio; };
	auto chk = [&](double ratio) -> bool { return (ig > 0.0) ? ratio > 0.0 : ratio < 0.0; };

	double crat = ratio(fo, fi);
	do {
		h = nh(h, crat);
		zs zn = navi->z() + h;
		moveWait(zn);
		fo = fi;
		zo = zi;
		fi = cam->focusValue();
		zi = zn;
		crat = ratio(fo, fi);
		cout << h << "\n";
	} while (chk(crat));
	moveWait(navi->z() - h);

	//searchGlobal();
}

void Autofocus::searchScan(double speed) {
	zs guess = initialGuess(0.005);
	zs h = 40.0 * guess;
	if (h == 0.0) return;
	double oval = 0.0;
	auto nval = cam->focusValue();
	navi->setSpeed(speed);
	navi->moveToZ(navi->z() + h);
	int fail = 0;
	zs bz = navi->z();
	zs cz = bz;
	double bv = nval;
	while (fail < 4) {
		while (cam->focusValue() == nval) this_thread::sleep_for(milliseconds{ 5 });
		oval = nval;
		nval = cam->focusValue();
		cz = navi->z();
		//cout << nval << "\t" << cz << "\n";
		if (nval < oval) ++fail;
		if (nval > bv) {
			bz = cz;
			bv = nval;
		}
	}
	navi->stop();
	this_thread::sleep_for(milliseconds{ 5 });
	moveWait(bz);
	//cout << cam->focusValue() << "\t" << bz << "\n";
	navi->setSpeed(100.0);
}

void Autofocus::globalSearch() {
	async(launch::async, [this]() { searchGlobal(0.001); });
}

void Autofocus::adaptiveSearch() {
	async(launch::async, [this]() { searchAdaptive(); });
}

void Autofocus::derivativeSearch() {
	async(launch::async, [this]() { searchDerivative(); });
}

void Autofocus::scanSearch() {
	async(launch::async, [this]() { searchScan(); searchScan(0.5); emit focusFound(); });
}

void Autofocus::slowSearch() {
	async(launch::async, [this]() { searchScan(0.5); emit focusFound(); });
}