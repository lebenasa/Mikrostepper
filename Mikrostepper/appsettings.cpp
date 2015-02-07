#include "stdafx.h"
#include "appsettings.h"

#include "tinyxml2.h"

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
{
    setting = new QSettings{QSettings::IniFormat, QSettings::UserScope, "Miconos", "Optilab", this};
}

AppSettings::~AppSettings()
{

}

int AppSettings::readInt(const QString &name, int defval) {
    int val = setting->value(name, defval).toInt();
    return val;
}

double AppSettings::readDouble(const QString &name, double defval) {
    double val = setting->value(name, defval).toDouble();
    return val;
}

QString AppSettings::readString(const QString &name, const QString &defval) {
    QString val = setting->value(name, defval).toString();
    return val;
}

QSizeF AppSettings::readSize(const QString &name, const QSizeF &defval) {
    QSizeF val = setting->value(name, defval).toSizeF();
    return val;
}

QPointF AppSettings::readPoint(const QString &name, const QPointF &defval) {
    QPointF val = setting->value(name, defval).toPointF();
    return val;
}

bool AppSettings::readBool(const QString &name, bool defval) {
    bool val = setting->value(name, defval).toBool();
    return val;
}

void AppSettings::saveSettings(const QString &name, const QVariant &val) {
    setting->setValue(name, val);
    emit settingsChanged();
}

void AppSettings::eraseSettings(const QString &name) {
    setting->remove(name);
    emit settingsChanged();
}

int AppSettings::checkProfileCount() {
    setting->beginGroup("Profile");
    auto val = readInt("size", 0);
    setting->endGroup();
    return val;
}

int AppSettings::getActiveProfileId() {
    setting->beginGroup("Profile");
    auto val = readInt("active", 0);
    setting->endGroup();
    return val;
}

void AppSettings::setActiveProfileId(int id) {
    setting->beginGroup("Profile");
    saveSettings("active", id);
    setting->endGroup();
    emit profileIdChanged(id);
}

QString AppSettings::readProfileName(int id) {
    setting->beginReadArray("Profile");
    setting->setArrayIndex(id);
    auto val = readString("name", "empty");
    setting->endArray();
    return val;
}

double AppSettings::readProfileWidth(int id) {
    setting->beginReadArray("Profile");
    setting->setArrayIndex(id);
    auto val = readDouble("width", 0.0);
    setting->endArray();
    return val;
}

double AppSettings::readProfileHeight(int id) {
    setting->beginReadArray("Profile");
    setting->setArrayIndex(id);
    auto val = readDouble("height", 0.0);
    setting->endArray();
    return val;
}

void AppSettings::beginUpdateProfile() {
    profiles.clear();
}

void AppSettings::updateProfile(const QString &name, const double &width, const double &height) {
    Profile profile;
    profile.name = name;
    profile.width = width;
    profile.height = height;
    profiles.push_back(profile);
}

void AppSettings::endUpdateProfile() {
    setting->beginWriteArray("Profile");
    for (size_t i = 0; i < profiles.size(); ++i) {
        setting->setArrayIndex((int)i);
        setting->setValue("name", profiles.at(i).name);
        setting->setValue("width", profiles.at(i).width);
        setting->setValue("height", profiles.at(i).height);
    }
    setting->endArray();
    emit profileUpdated();
}

void AppSettings::resetProfile() {
    beginUpdateProfile();
    updateProfile("4x", 2560.0, 1913);
    updateProfile("10x", 1024.0, 775.0);
    updateProfile("40x", 364.0, 245.0);
    updateProfile("100x", 102.0, 78.0);
    endUpdateProfile();
}

QString AppSettings::readShortcut(const QString &command, const QString& defkey) {
    setting->beginGroup("Shortcuts");
    auto key = readString(command, defkey);
    setting->endGroup();
    return key;
}

void AppSettings::saveShortcut(const QString &command, const QString &key) {
    setting->beginGroup("Shortcuts");
    saveSettings(command, key);
    setting->endGroup();
    emit shortcutUpdated();
}

QString AppSettings::keyCodeToString(int key) {
    QKeySequence seq(key);
//    qDebug() << seq.toString();
    return seq.toString();
}

void AppSettings::resetShortcut(const QString &command) {
    setting->beginGroup("Shortcuts");
    setting->remove(command);
    setting->endGroup();
    emit shortcutUpdated();
}

void AppSettings::resetAllShortcut() {
    setting->beginGroup("Shortcuts");
    setting->remove("");
    setting->endGroup();
    emit shortcutUpdated();
}

double AppSettings::readCNCStepsPerUnitX() {
	auto dir = QCoreApplication::applicationDirPath();
	dir += "/CNCUSBController.setting";
	auto xml = QDir::toNativeSeparators(dir);
	tinyxml2::XMLDocument doc;
	auto err = doc.LoadFile(xml.toStdString().c_str());
	if (err == tinyxml2::XML_NO_ERROR) {
		auto spx = doc.FirstChildElement("Setting")->FirstChildElement("Axis1StepsPerUnit")->FirstChild()->ToText();
		QString txt{ spx->Value() };
		return txt.toDouble();
	}
	return 0.0;
}

double AppSettings::readCNCStepsPerUnitY() {
	auto dir = QCoreApplication::applicationDirPath();
	dir += "/CNCUSBController.setting";
	auto xml = QDir::toNativeSeparators(dir);
	tinyxml2::XMLDocument doc;
	auto err = doc.LoadFile(xml.toStdString().c_str());
	if (err == tinyxml2::XML_NO_ERROR) {
		auto spx = doc.FirstChildElement("Setting")->FirstChildElement("Axis2StepsPerUnit")->FirstChild()->ToText();
		QString txt{ spx->Value() };
		return txt.toDouble();
	}
	return 0.0;
}

double AppSettings::readCNCStepsPerUnitZ() {
	auto dir = QCoreApplication::applicationDirPath();
	dir += "/CNCUSBController.setting";
	auto xml = QDir::toNativeSeparators(dir);
	tinyxml2::XMLDocument doc;
	auto err = doc.LoadFile(xml.toStdString().c_str());
	if (err == tinyxml2::XML_NO_ERROR) {
		auto spx = doc.FirstChildElement("Setting")->FirstChildElement("Axis3StepsPerUnit")->FirstChild()->ToText();
		QString txt{ spx->Value() };
		return txt.toDouble();
	}
	return 0.0;
}

void AppSettings::updateCNCSettings() {
	bool cx, cy, cz;
	cx = cy = cz = false;
	auto spx = readDouble("StepPerUnitX", 5096.0);
	if (spx != readCNCStepsPerUnitX()) cx = true;
	auto spy = readDouble("StepPerUnitY", 5096.0);
	if (spy != readCNCStepsPerUnitY()) cy = true;
	auto spz = readDouble("StepPerUnitZ", 1067.0);
	if (spz != readCNCStepsPerUnitZ()) cz = true;
	QStringList args;
	args << QString().setNum((int)spx) << QString().setNum((int)spy) << QString().setNum((int)spz);
	if (cx || cy || cz) {
		auto dir = QCoreApplication::applicationDirPath();
		dir += "/CNCUSBController.setting";
		auto xml = QDir::toNativeSeparators(dir);
		tinyxml2::XMLDocument doc;
		auto err = doc.LoadFile(xml.toStdString().c_str());
		if (err == tinyxml2::XML_NO_ERROR) {
			auto aspx = doc.FirstChildElement("Setting")->FirstChildElement("Axis1StepsPerUnit")->FirstChild()->ToText();
			aspx->SetValue(args.at(0).toStdString().c_str());
			auto aspy = doc.FirstChildElement("Setting")->FirstChildElement("Axis2StepsPerUnit")->FirstChild()->ToText();
			aspy->SetValue(args.at(1).toStdString().c_str());
			auto aspz = doc.FirstChildElement("Setting")->FirstChildElement("Axis3StepsPerUnit")->FirstChild()->ToText();
			aspz->SetValue(args.at(2).toStdString().c_str());
			doc.SaveFile(xml.toStdString().c_str());
		}
	}
}