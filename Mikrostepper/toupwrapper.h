#ifndef TOUPWRAPPER_H
#define TOUPWRAPPER_H

#include <QObject>
#include <QSize>

#include "toupcam.h"

class Image : public QObject
{
public:
	Image() = default;
	Image(int w, int h, int c);
	~Image();

	Image(const Image&) = delete;
	Image& operator=(const Image&) = delete;

	Image& operator=(Image&&);

	QImage image();
	uchar* buffer();
	uchar* buffer() const;

protected:
	int width, height, channel;
	uchar* m_buffer;
};

void CALLBACK toup_callback(unsigned nEvent, void* pCallbackCtx);

class ToupWrapper : public QObject
{
	Q_OBJECT
	ToupcamInst arrinst[TOUPCAM_MAX];
	HToupCam htoupcam;
	bool m_available;
	QSize m_size;
	size_t m_still;
public:
	ToupWrapper(QObject* parent = nullptr);
	~ToupWrapper();

	void cbImageReady();
	void cbStillImageReady();
	void cbCameraError();

	bool isAvailable() const;

	size_t resolution();
	QSize size() const;
	std::vector<QSize> sizes();

	size_t stillResolution() const;
	QSize stillSize();
	std::vector<QSize> stillSizes();

	QImage& pullImage();
	QImage& pullStillImage();

public slots:
	void setResolution(size_t res);
	void start();
	void stop();

	void snap(size_t res);

signals:
	void imageReady();
	void stillImageReady();
	void cameraError();
	void sizeChanged(const QSize&);

private:
	void init();
	void close();
	void updateSize();
};


#endif // TOUPWRAPPER_H
