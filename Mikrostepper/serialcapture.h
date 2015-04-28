#ifndef SERIALCAPTURE_H
#define SERIALCAPTURE_H

#include <QObject>
#include "qqmlapplicationengine.h"
#include "qqmlcontext.h"

#include "autofocus.h"

class Camera;
class StepperNavigator;
class CameraModel;
class StepperInterface;

using Command = std::function < void() > ;
using CommandPool = std::queue < Command >;

class SerialCapture : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QSize cellSize READ cellSize NOTIFY cellSizeChanged)
	Q_PROPERTY(bool block MEMBER m_block NOTIFY blockChanged)
    Q_PROPERTY(int selectCounter MEMBER selectCounter NOTIFY selectCounterChanged)
    Q_PROPERTY(bool focus READ focus WRITE setFocus NOTIFY focusChanged)
	
public:
    SerialCapture(Camera* camera, StepperNavigator* navigator, QObject *parent = 0);
	~SerialCapture();

	QSize cellSize() const;
	void setCellSize(const QSize &size);

    void setQmlContext(QQmlContext* context);

    QPoint currentIndex();
    QPointF currentCoord();

    bool focus() const { return m_focus; }
    void setFocus(bool);

public slots:
    void updateCenter();

	void zoomIn();
    void zoomOut();

	void blockStream();
	void unblockStream();
	void redirectImage(const QImage& img);

	void moveToSelected(bool autofocus);

    void procSelect(const QPoint& pos);
    void procHighlight(const QPoint& pos);
    
    void beginMultiSelect(const QPoint& pos);
    void endMultiSelect(const QPoint& pos);
    
    void boxFill(bool autofocus);
    void autoFill(bool autofocus);

    void shiftUp();
    void shiftDown();
    void shiftLeft();
    void shiftRight();

    void nextCommand();

    void addCommand(Command);
    void addMoveToCommand(const QPointF& target);
    void addBlockCommand(int msecond);
	void addSearchFocusCommand();
    void flushCommand();

signals:
    void currentPosChanged(const QPoint& xy);
	void cellSizeChanged(const QSize &size);
	void blockChanged(bool);
    void selectCounterChanged(int nv);
    void autoFillFailed();
    void focusChanged(bool);
	void searchFocusChanged(bool);

private:
    Camera* m_camera;
    StepperNavigator* m_navigator;
	Autofocus autofocus;
	CameraModel* m_model;
    StepperInterface* m_interface;
	QQmlContext* rootContext;

	QSize m_size;	// cell size, i.e for implementing zoom
	int m_zoom;
    bool m_block, m_focus;
    
    QPoint lastHighlight, select1;
    int selectCounter = 0;

    CommandPool commandPool;
};

#endif // SERIALCAPTURE_H
