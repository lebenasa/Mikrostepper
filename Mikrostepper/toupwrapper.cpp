#include "stdafx.h"
#include "toupwrapper.h"
using namespace std;

Image::Image(int w, int h, int c)
	: width{ w }, height{ h }, channel{ c }, m_buffer{ new uchar[w * h * c] }
{ }

Image::~Image()
{
	if (m_buffer) delete[] m_buffer;
}

Image& Image::operator=(Image&& im)
{
	width = im.width;
	height = im.height;
	channel = im.channel;
	m_buffer = im.m_buffer;
	im.m_buffer = nullptr;
	return *this;
}

QImage Image::image()
{
	return QImage{ m_buffer, width, height, QImage::Format_RGB888 };
}

uchar* Image::buffer()
{
	return m_buffer;
}

uchar* Image::buffer() const
{
	return m_buffer;
}

ToupWrapper::ToupWrapper(QObject* parent)
	: QObject(parent), m_available{ false }
{
	init();
	start();
	//setResolution(arrinst[0].model->preview - 2);
}

ToupWrapper::~ToupWrapper()
{
	stop();
	close();
}

void ToupWrapper::setResolution(size_t res)
{
	stop();
	Toupcam_put_eSize(htoupcam, res);
	init();
	start();
}

void ToupWrapper::init()
{
	auto cnt = Toupcam_Enum(arrinst);
	if (cnt > 0)
	{
		htoupcam = Toupcam_Open(0);
		updateSize();
		m_available = true;
	}
	else
		m_available = false;
}

void ToupWrapper::close()
{
	Toupcam_Close(htoupcam);
	m_available = false;
}

void ToupWrapper::updateSize()
{
	int w, h;
	Toupcam_get_Resolution(htoupcam, resolution(), &w, &h);
	m_size = QSize{ w, h };
	emit sizeChanged(m_size);
}

void CALLBACK toup_callback(unsigned nEvent, void* pCallbackCtx)
{
	auto toup = (ToupWrapper*)pCallbackCtx;
	switch (nEvent)
	{
	case TOUPCAM_EVENT_IMAGE:
		toup->cbImageReady();
		break;
	case TOUPCAM_EVENT_STILLIMAGE:
		toup->cbStillImageReady();
		break;
	case TOUPCAM_EVENT_ERROR:
	case TOUPCAM_EVENT_DISCONNECTED:
		toup->cbCameraError();
		break;
	}
}

void ToupWrapper::start()
{
	if (m_available) Toupcam_StartPullModeWithCallback(htoupcam,
		toup_callback, this);
}

void ToupWrapper::stop()
{
	Toupcam_Stop(htoupcam);
}

bool ToupWrapper::isAvailable() const
{
	return m_available;
}

void ToupWrapper::cbImageReady()
{
	emit imageReady();
}

QImage& ToupWrapper::pullImage()
{
	Image im{ m_size.width(), m_size.height(), 3 };
	Toupcam_PullImage(htoupcam, im.buffer(), 24, nullptr, nullptr);
	auto img = im.image().copy();
	return move(img);
}

void ToupWrapper::snap(size_t res)
{
	m_still = res;
	Toupcam_Snap(htoupcam, res);
}

void ToupWrapper::cbStillImageReady()
{
	emit stillImageReady();
}

QImage& ToupWrapper::pullStillImage()
{
	auto still_sz = stillSize();
	Image im{ still_sz.width(), still_sz.height(), 3 };
	Toupcam_PullStillImage(htoupcam, im.buffer(), 24, nullptr, nullptr);
	return move(im.image().copy());
}

void ToupWrapper::cbCameraError()
{
	m_available = false;
	emit cameraError();
}

size_t ToupWrapper::resolution()
{
	size_t res;
	Toupcam_get_eSize(htoupcam, &res);
	return res;
}

QSize ToupWrapper::size() const 
{
	return m_size;
}

vector<QSize> ToupWrapper::sizes()
{
	vector<QSize> res;
	auto model = arrinst[0].model;
	size_t cnt = model->preview;
	for (auto i = 0u; i < cnt; ++i)
	{
		int w, h;
		Toupcam_get_Resolution(htoupcam, i, &w, &h);
		res.emplace_back(QSize{ w, h });
	}
	return move(res);
}

size_t ToupWrapper::stillResolution() const
{
	return m_still;
}

QSize ToupWrapper::stillSize()
{
	return stillSizes().at(m_still);
}

vector<QSize> ToupWrapper::stillSizes()
{
	vector<QSize> res;
	auto model = arrinst[0].model;
	size_t cnt = model->still;
	for (auto i = 0u; i < cnt; ++i)
	{
		int w, h;
		Toupcam_get_StillResolution(htoupcam, i, &w, &h);
		res.emplace_back(QSize{ w, h });
	}
	return move(res);
}