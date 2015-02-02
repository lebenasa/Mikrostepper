#include "stdafx.h"
#include "baserecorder.h"

#include "DSCAMAPI.h"

BaseRecorder::BaseRecorder(QObject *parent)
  : QObject(parent), m_file(""), m_fps(25.0), timestarted(0, 0, 0, 0)
{
    timer = new QTimer(this);
    timer->setTimerType(Qt::PreciseTimer);
    connect(timer, &QTimer::timeout, this, &BaseRecorder::timeout);
}

BaseRecorder::~BaseRecorder()
{
	if (writer.isOpened())
		writer.release();
}

void BaseRecorder::initRecorder(const QString &video_file, double frame_rate) {
    timer->stop();
    m_file = video_file;
    m_fps = frame_rate;
    timestarted = QTime(0, 0, 0, 0);
    timer->setInterval(1000/frame_rate);
	if (QFile::exists(video_file)) QFile::remove(video_file);
	int sW, sH;
	CameraGetImageSize(&sW, &sH);
	auto writer = cv::VideoWriter{ };
	bool result = writer.open(video_file.toStdString(), cv::VideoWriter::fourcc('D', 'I', 'V', 'X'), frame_rate, cv::Size(sW, sH));
}

void BaseRecorder::imgProc(const QImage &img) {
    im_frame = img;
}

void BaseRecorder::timeout() {
	cv::Mat cFrame{ im_frame.width(), im_frame.height(), CV_8UC3, im_frame.bits(), (size_t)im_frame.bytesPerLine() };
	writer << cFrame;
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
	writer.release();
}
