#include "stdafx.h"
#include "camprop.h"

CamProp::CamProp(QObject *parent)
	: QObject(parent)
{

}

CamProp::~CamProp()
{

}

void CamProp::saveParametersA()
{

}

void CamProp::loadParametersA()
{

}

void CamProp::saveParametersB()
{

}

void CamProp::loadParametersB()
{

}

void CamProp::saveParametersC()
{

}

void CamProp::loadParametersC()
{

}

void CamProp::saveParametersD()
{

}

void CamProp::loadParametersD()
{

}

void CamProp::reloadParams()
{

}

int CamProp::getCurrentParameterTeam()
{
	return 0;
}

NullCamProp::NullCamProp(QObject* parent)
	: CamProp{ parent }
{

}

double NullCamProp::hue() const
{
	return 0;
}

void NullCamProp::setHue(double) 
{

}

double NullCamProp::saturation() const
{
	return 0;
}

void NullCamProp::setSaturation(double val)
{
}

double NullCamProp::brightness() const
{
	return 0;
}

void NullCamProp::setBrightness(double val)
{
}

double NullCamProp::contrast() const
{
	return 0;
}

void NullCamProp::setContrast(double val)
{
}

double NullCamProp::gamma() const
{
	return 0;
}

void NullCamProp::setGamma(double val)
{
}

bool NullCamProp::autoexposure() const
{
	return false;
}

void NullCamProp::setAutoexposure(bool val)
{
}

double NullCamProp::aeGain() const
{
	return 0;
}

void NullCamProp::setAeGain(double val)
{
}

double NullCamProp::exposureTime() const
{
	return 0;
}

void NullCamProp::setExposureTime(double val)
{
}

double NullCamProp::aeTarget() const
{
	return 0;
}

void NullCamProp::setAeTarget(double val)
{
}

double NullCamProp::maxExposureTime()
{
	return 0;
}

double NullCamProp::rGain() const
{
	return 0;
}

void NullCamProp::setRGain(double val)
{
}

double NullCamProp::gGain() const
{
	return 0;
}

void NullCamProp::setGGain(double val)
{
}

double NullCamProp::bGain() const
{
	return 0;
}

void NullCamProp::setBGain(double val)
{
}

double NullCamProp::whiteBalanceTemperature() const
{
	return 0;
}

void NullCamProp::setWhiteBalanceTemperature(double val)
{
}

double NullCamProp::whiteBalanceTint() const
{
	return 0;
}

void NullCamProp::setWhiteBalanceTint(double val)
{
}

int NullCamProp::frameRate() const
{
	return 0;
}

void NullCamProp::setFrameRate(int fr)
{
}

bool NullCamProp::isColor() const
{
	return true;
}

void NullCamProp::setColorMode(bool mode)
{
}

bool NullCamProp::isHFlip() const
{
	return true;
}

void NullCamProp::setHFlip(bool flip)
{
}

bool NullCamProp::isVFlip() const
{
	return true;
}

void NullCamProp::setVFlip(bool flip)
{
}

bool NullCamProp::isBin() const
{
	return true;
}

void NullCamProp::setSamplingMode(bool mode)
{
}

QRect NullCamProp::whiteBalanceBox() const
{
	return QRect{};
}

void NullCamProp::setWhiteBalanceBox(const QRect& r)
{
}

void NullCamProp::oneShotWB()
{
}

void NullCamProp::loadDefaultParameters()
{
}

