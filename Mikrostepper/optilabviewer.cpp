#include "stdafx.h"
#include "optilabviewer.h"

OptilabViewer::OptilabViewer(Camera *parent)
    : QObject(parent), m_camera(parent), m_recorder(this), en_recording(WaitForFile)
{
    //Set working directory:
    QString tempPath = QStandardPaths::standardLocations(QStandardPaths::TempLocation).at(0) + "/Optilab/";
    QDir workdir(tempPath);
    if (workdir.exists())
        QDir::setCurrent(tempPath);
    else {
        workdir.mkpath(workdir.path());
        QDir::setCurrent(workdir.path());
    }
    auto list = workdir.entryList(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
    for (auto file : list)
        workdir.remove(file);
    connect(m_camera, &Camera::frameReady, &m_recorder, &BaseRecorder::imgProc);
    connect(&m_recorder, &BaseRecorder::timestatus, this, &OptilabViewer::recordingTime);
}

OptilabViewer::~OptilabViewer()
{
    m_recorder.stop();
}

QSize OptilabViewer::calculateAspectRatio(int screenWidth, int screenHeight) const {
    QSize screenSize{ screenWidth, screenHeight };
    auto sourceSize = m_camera->size();
    double aspectRatio = 1.0 * sourceSize.width() / sourceSize.height();
    double screenRatio = 1.0 * screenSize.width() / screenSize.height();
    int frameWidth, frameHeight;
    int hOffset, vOffset;
    hOffset = vOffset = 0;
    if (aspectRatio > screenRatio) {
        frameWidth = screenSize.width();
        frameHeight = 1.0 * screenSize.width() / aspectRatio;
        vOffset = (screenSize.height() - frameHeight) / 2;
    }
    else {
        frameWidth = 1.0 * screenSize.height() * aspectRatio;
        frameHeight = screenSize.height();
        hOffset = (screenSize.width() - frameWidth) / 2;
    }
    return QSize{ hOffset, vOffset };
}

QUrl OptilabViewer::captureToTemp(const QString& imgName) {
    QString appPath = QDir::currentPath();
    QString img = appPath + "/" + imgName;
    if (QFile::exists(img))
        QFile::remove(img);
    m_camera->capture(0, img); // 0 = Highest, 2 = Lowest
    return QUrl::fromLocalFile(img);
}

void OptilabViewer::copyFromTemp(const QString &imgName, const QUrl &fullPath) {
    if (QFile::exists(fullPath.toLocalFile()))
        QFile::remove(fullPath.toLocalFile());
    QFile::copy(imgName, fullPath.toLocalFile());
}

void OptilabViewer::copyToFolder(const QUrl &image, const QUrl &folder) {
    QString img = image.toLocalFile();
    QString path = folder.toLocalFile();
    QFileInfo imfile(img);
    path += "/" + imfile.fileName();
    QFile::copy(img, path);
}

void OptilabViewer::addCommand(Command cmd) {
    commandPool.push(cmd);
}

void OptilabViewer::nextCommand() {
    if (!commandPool.empty()) {
        auto cmd = commandPool.front();
        cmd();
        commandPool.pop();
        emit remainingCommand(commandPool.size());
    }
}

void OptilabViewer::addCaptureCommand(const QString &imgName) {
    addCommand([=]() { captureToTemp(imgName); nextCommand(); });
}

void OptilabViewer::addWaitCommand(int msecond) {
    addCommand([=]() { QTimer::singleShot(msecond, this, SLOT(nextCommand())); });
}

void OptilabViewer::addCaptureWaitCommand(const QString &imgName, int msecond){
    addCommand([=]() {
        emit imageSaved(captureToTemp(imgName));
        QTimer::singleShot(msecond, this, SLOT(nextCommand()));
    });
}

void OptilabViewer::flushCommands() {
    while (!commandPool.empty())
        commandPool.pop();
}

QStringList OptilabViewer::startSerialCapture(int interval, int fcount) {
    QStringList namelist;
    for (int i = 0; i < fcount; ++i) {
        QString fn = QString("IMG_%1.jpg").arg(i, 4, 10, QChar('0'));
        addCaptureWaitCommand(fn, interval);
        namelist.append(fn);
    }
    nextCommand();
    return namelist;
}

void OptilabViewer::initRecorder(const QUrl &video) {
    m_recorder.initRecorder(video.toLocalFile());
    m_recorder.start();
    en_recording = Recording;
    emit recordingStatusChanged();
}

void OptilabViewer::pauseRecording() {
    m_recorder.pause();
    en_recording = Paused;
    emit recordingStatusChanged();
}

void OptilabViewer::resumeRecording() {
    m_recorder.start();
    en_recording = Recording;
    emit recordingStatusChanged();
}

void OptilabViewer::stopRecording() {
    m_recorder.stop();
    en_recording = WaitForFile;
    emit recordingStatusChanged();
}
