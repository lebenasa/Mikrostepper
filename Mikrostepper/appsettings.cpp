#include "stdafx.h"
#include "appsettings.h"

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
