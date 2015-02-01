#include "stdafx.h"
#include "cameracontrol.h"

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
    return _rg;
}

void CameraControl::setRGain(double val) {
    if (rGain() != val) {
        _rg = val;
        emit rGainChanged(val);
    }
}

double CameraControl::gGain() const {
    return _gg;
}

void CameraControl::setGGain(double val) {
    if (gGain() != val) {
        _gg = val;
        emit gGainChanged(val);
    }
}

double CameraControl::bGain() const {
    return _bg;
}

void CameraControl::setBGain(double val) {
    if (bGain() != val) {
        _bg = val;
        emit bGainChanged(val);
    }
}

double CameraControl::gamma() const {
    return _gamma;
}

void CameraControl::setGamma(double val) {
    if (gamma() != val) {
        _gamma = val;
        emit gammaChanged(val);
    }
}

double CameraControl::contrast() const {
    return _contrast;
}

void CameraControl::setContrast(double val) {
    if (contrast() != val) {
        _contrast = val;
        emit contrastChanged(val);
    }
}

double CameraControl::saturation() const {
    return _saturation;
}

void CameraControl::setSaturation(double val) {
    if (saturation() != val) {
        _saturation = val;
        emit saturationChanged(val);
    }
}

bool CameraControl::autoexposure() const {
    return _ae;
}

void CameraControl::setAutoexposure(bool val) {
    if (autoexposure() != val) {
        _ae = val;
        emit autoexposureChanged(val);
    }
}

double CameraControl::aeGain() const {
    return _aegain;
}

void CameraControl::setAeGain(double val) {
    if (aeGain() != val) {
        _aegain = val;
        emit aeGainChanged(val);
    }
}

double CameraControl::exposureTime() const {
    return _exptime;
}

double CameraControl::maxExposureTime() {
    return 300;
}

void CameraControl::setExposureTime(double val) {
    if (exposureTime() != val) {
        _exptime = val;
        emit exposureTimeChanged(val);
    }
}

double CameraControl::aeTarget() const {
    return _aetarget;
}

void CameraControl::setAeTarget(double val) {
    if (aeTarget() != val) {
        _aetarget = val;
        emit aeTargetChanged(val);
    }
}

void CameraControl::oneShotWB() {

}

void CameraControl::saveParametersA() {

}

void CameraControl::loadParametersA() {

}

void CameraControl::saveParametersB() {

}

void CameraControl::loadParametersB() {

}

void CameraControl::saveParametersC() {

}

void CameraControl::loadParametersC() {

}

void CameraControl::saveParametersD() {

}

void CameraControl::loadParametersD() {

}

void CameraControl::loadDefaultParameters() {

}






