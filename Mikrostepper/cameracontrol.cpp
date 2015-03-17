#include "stdafx.h"
#include "cameracontrol.h"

#include "DSCAMAPI.h"

CameraControl::CameraControl(QObject *parent) : QObject(parent)
{
    _gamma = 45;
    _contrast = 80;
    _saturation = 120;
    _ae = true;
    _aetarget = 100;
    _exptime = 300;
    _aegain = 20;
    _rg = 74;
    _gg = 64;
    _bg = 96;
}

CameraControl::~CameraControl()
{

}

double CameraControl::rGain() const {
	int rg, gg, bg;
	CameraGetGain(&rg, &gg, &bg);
    return rg;
}

void CameraControl::setRGain(double val) {
	int rg, gg, bg;
	CameraGetGain(&rg, &gg, &bg);
    if (rg != int(val)) {
		rg = int(val);
		CameraSetGain(rg, gg, bg);
        emit rGainChanged(val);
    }
}

double CameraControl::gGain() const {
	int rg, gg, bg;
	CameraGetGain(&rg, &gg, &bg);
	return 1.0 * gg;
}

void CameraControl::setGGain(double val) {
	int rg, gg, bg;
	CameraGetGain(&rg, &gg, &bg);
	if (gg != int(val)) {
		gg = int(val);
		CameraSetGain(rg, gg, bg);
		emit rGainChanged(val);
	}
}

double CameraControl::bGain() const {
	int rg, gg, bg;
	CameraGetGain(&rg, &gg, &bg);
	return 1.0 * bg;
}

void CameraControl::setBGain(double val) {
	int rg, gg, bg;
	CameraGetGain(&rg, &gg, &bg);
	if (bg != int(val)) {
		bg = int(val);
		CameraSetGain(rg, gg, bg);
		emit rGainChanged(val);
	}
}

double CameraControl::gamma() const {
	uchar ga;
	CameraGetGamma(&ga);
	return 1.0 * ga;
}

void CameraControl::setGamma(double val) {
    if (gamma() != val) {
		CameraSetGamma((uchar)val);
        emit gammaChanged(val);
    }
}

double CameraControl::contrast() const {
	uchar cont;
	CameraGetContrast(&cont);
	return 1.0 * cont;
}

void CameraControl::setContrast(double val) {
    if (contrast() != val) {
		CameraSetContrast((uchar)val);
        emit contrastChanged(val);
    }
}

double CameraControl::saturation() const {
	uchar sat;
	CameraGetSaturation(&sat);
	return 1.0 * sat;
}

void CameraControl::setSaturation(double val) {
    if (saturation() != val) {
		CameraSetSaturation((uchar)val);
        emit saturationChanged(val);
    }
}

bool CameraControl::autoexposure() const {
	BOOL AE;
	CameraGetAeState(&AE);
	return (AE == TRUE);
}

void CameraControl::setAutoexposure(bool val) {
    if (autoexposure() != val) {
		BOOL v = val ? TRUE : FALSE;
		CameraSetAeState(v);
        emit autoexposureChanged(val);
		emit aeGainChanged(aeGain());
		emit aeTargetChanged(aeTarget());
		emit exposureTimeChanged(exposureTime());
    }
}

double CameraControl::aeGain() const {
	ushort AEG;
	CameraGetAnalogGain(&AEG);
	return 1.0 * AEG;
}

void CameraControl::setAeGain(double val) {
    if (aeGain() != val) {
		CameraSetAnalogGain((ushort)val);
        emit aeGainChanged(val);
    }
}

double CameraControl::exposureTime() const {
	int tm;
	CameraGetExposureTime(&tm);
	return 1.0 * tm;
}

double CameraControl::maxExposureTime() {
	ushort tmx;
	CameraGetMaxExposureTime(&tmx);
	return 1.0 * tmx;
}

void CameraControl::setExposureTime(double val) {
    if (exposureTime() != val) {
		CameraSetExposureTime((int)val);
        emit exposureTimeChanged(val);
    }
}

double CameraControl::aeTarget() const {
	uchar tgt;
	CameraGetAeTarget(&tgt);
	return 1.0 * tgt;
}

void CameraControl::setAeTarget(double val) {
    if (aeTarget() != val) {
		CameraSetAeTarget((uchar)val);
        emit aeTargetChanged(val);
    }
}

void CameraControl::oneShotWB() {
	CameraSetAWBState(TRUE);
}

void CameraControl::reloadParams() {
	CameraSetB2RGBMode(DS_B2RGB_MODE::B2RGB_MODE_LINE);
	CameraSetColorEnhancement(TRUE);
	CameraSetLightFrquency(DS_LIGHT_FREQUENCY::LIGHT_FREQUENCY_60HZ);
	CameraSetFrameSpeed(DS_FRAME_SPEED::FRAME_SPEED_NORMAL);
	CameraSetMirror(DS_MIRROR_DIRECTION::MIRROR_DIRECTION_HORIZONTAL, FALSE);
	CameraSetMirror(DS_MIRROR_DIRECTION::MIRROR_DIRECTION_VERTICAL, FALSE);
	emit rGainChanged(rGain());
	emit gGainChanged(gGain());
	emit bGainChanged(bGain());
	emit gammaChanged(gamma());
	emit contrastChanged(contrast());
	emit saturationChanged(saturation());
	emit autoexposureChanged(autoexposure());
	emit aeGainChanged(aeGain());
	emit aeTargetChanged(aeTarget());
	emit exposureTimeChanged(exposureTime());
}

void CameraControl::saveParametersA() {
	CameraSaveParameter(PARAMETER_TEAM_A);
}

void CameraControl::loadParametersA() {
	CameraReadParameter(PARAMETER_TEAM_A);
	reloadParams();
}

void CameraControl::saveParametersB() {
	CameraSaveParameter(PARAMETER_TEAM_B);
}

void CameraControl::loadParametersB() {
	CameraReadParameter(PARAMETER_TEAM_B);
	reloadParams();
}

void CameraControl::saveParametersC() {
	CameraSaveParameter(PARAMETER_TEAM_C);
}

void CameraControl::loadParametersC() {
	CameraReadParameter(PARAMETER_TEAM_C);
	reloadParams();
}

void CameraControl::saveParametersD() {
	CameraSaveParameter(PARAMETER_TEAM_D);
}

void CameraControl::loadParametersD() {
	CameraReadParameter(PARAMETER_TEAM_D);
	reloadParams();
}

void CameraControl::loadDefaultParameters() {
	CameraLoadDefault();
	reloadParams();
}

int CameraControl::getCurrentParameterTeam() {
	uchar pt;
	CameraGetCurrentParameterTeam(&pt);
	return (int)pt;
}

void CameraControl::setFrameSpeed(int speed) {
	auto spd = (speed < 0) ? 0 : (speed > 2) ? 2 : speed;
	CameraSetFrameSpeed((DS_FRAME_SPEED)spd);
}




