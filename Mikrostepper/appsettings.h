#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QSettings>

struct Profile {
    QString name;
    double width, height;
};

class AppSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int profileId READ getActiveProfileId WRITE setActiveProfileId NOTIFY profileIdChanged)
    QSettings* setting;
    std::vector<Profile> profiles;
public:
    explicit AppSettings(QObject *parent = 0);
    ~AppSettings();

signals:
    void settingsChanged();
    void profileIdChanged(int id);
    void profileUpdated();
    void shortcutUpdated();

public slots:
    int readInt(const QString& name, int defval = 0);
    double readDouble(const QString& name, double defval = 0.0);
    QString readString(const QString& name, const QString& defval = "");
    QSizeF readSize(const QString& name, const QSizeF& defval = QSizeF());
    QPointF readPoint(const QString& name, const QPointF& defval = QPointF());
    bool readBool(const QString& name, bool defval = false);

    void saveSettings(const QString& name, const QVariant& val);
    void eraseSettings(const QString& name);

    int checkProfileCount();
    int getActiveProfileId();
    void setActiveProfileId(int id);

    QString readProfileName(int id);
    double readProfileWidth(int id);
    double readProfileHeight(int id);

    void beginUpdateProfile();
    void updateProfile(const QString& name, const double& width, const double& height);
    void endUpdateProfile();

    void resetProfile();

    QString readShortcut(const QString& command, const QString& defkey);
    void saveShortcut(const QString& command, const QString& key);
    QString keyCodeToString(int key);

    void resetShortcut(const QString& command);
    void resetAllShortcut();

	double readCNCStepsPerUnitX();
	double readCNCStepsPerUnitY();
	double readCNCStepsPerUnitZ();
};

#endif // APPSETTINGS_H
