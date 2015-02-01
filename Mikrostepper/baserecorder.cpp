#include "stdafx.h"
#include "baserecorder.h"

BaseRecorder::BaseRecorder(QObject *parent)
  : QObject(parent), m_file(""), m_fps(25.0), timestarted(0, 0, 0, 0)
{
    timer = new QTimer(this);
    timer->setTimerType(Qt::PreciseTimer);
    connect(timer, &QTimer::timeout, this, &BaseRecorder::timeout);
}

BaseRecorder::~BaseRecorder()
{

}

void BaseRecorder::initRecorder(const QString &video_file, double frame_rate) {
    timer->stop();
    m_file = video_file;
    m_fps = frame_rate;
    timestarted = QTime(0, 0, 0, 0);
    timer->setInterval(1000/frame_rate);
}

void BaseRecorder::imgProc(const QImage &img) {
    im_frame = img;
}

void BaseRecorder::timeout() {
    timestarted = timestarted.addMSecs(1000/m_fps);
    emit timestatus(timestarted.toString("hh:mm:ss"));
}

void BaseRecorder::start() {
    timer->start();
}

void BaseRecorder::pause() {
    timer->stop();
}

void BaseRecorder::stop() {
    timer->stop();
}
