#include "stdafx.h"
#include "baserecorder.h"

#include <future>

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
	if (writer) {
		if (writer->isOpened())
			writer->release();
	}
}

void BaseRecorder::initRecorder(const QString &video_file, double frame_rate) {
    timer->stop();
    m_file = video_file;
    m_fps = frame_rate;
    timestarted = QTime(0, 0, 0, 0);
    timer->setInterval(1000/frame_rate);
	if (QFile::exists(video_file)) QFile::remove(video_file);
	writer = std::make_unique<cv::VideoWriter>(cv::VideoWriter{});
	bool result = writer->open(QDir::toNativeSeparators(video_file).toStdString(), cv::VideoWriter::fourcc('D', 'I', 'V', 'X'), 
		frame_rate, frameSize);
}

void BaseRecorder::timeout() {
	//auto cframe = frame;
	cv::Mat cframe;
	std::mutex m;
	m.lock();
	cv::cvtColor(frame(), cframe, cv::COLOR_BGR2RGB);
	writer->write(cframe);
	m.unlock();
    timestarted = timestarted.addMSecs(1000/m_fps);
    emit timestatus(timestarted.toString("hh:mm:ss"));
}

void BaseRecorder::setFrame(const cv::Mat& fr) {
	m_frame = fr;
}

cv::Mat BaseRecorder::frame() const {
	return m_frame;
}

void BaseRecorder::start() {
    timer->start();
}

void BaseRecorder::pause() {
    timer->stop();
}

void BaseRecorder::stop() {
    timer->stop();
	writer->release();
	writer.release();
}
