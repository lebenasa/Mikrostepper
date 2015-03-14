#include "stdafx.h"
#include "serialcapture.h"
#include "camera.h"
#include "cameramodel.h"
#include "stepperinterface.h"
#include "steppernavigator.h"
using namespace std;

SerialCapture::SerialCapture(Camera *camera, StepperNavigator *navigator, QObject *parent)
    : QObject(parent), m_camera(camera), m_navigator(navigator), m_zoom(15), m_block(true), m_focus(true)
{
    m_interface = new StepperInterface(this);
    m_model = new CameraModel(m_interface->cellDims(), this);

    auto sz = m_camera->size();
    m_size = QSize(sz.width() / m_zoom, sz.height() / m_zoom);

    // Connections
    connect(m_interface, &StepperInterface::profileChanged, [this](){
        m_model->initModel(m_interface->cellDims().height(), m_interface->cellDims().width());});
    connect(m_interface, &StepperInterface::cellDimsChanged, [this](){
        m_model->initModel(m_interface->cellDims().height(), m_interface->cellDims().width());});
    connect(m_navigator, &StepperNavigator::bufferFull, this, &SerialCapture::unblockStream);
    connect(m_camera, &Camera::frameReady, this, &SerialCapture::redirectImage);
}

SerialCapture::~SerialCapture()
{
}

void SerialCapture::setQmlContext(QQmlContext *context) {
    if (!context) return;
    rootContext = context;
    rootContext->setContextProperty("serialcapture", this);
    rootContext->setContextProperty("cammodel", m_model);
    rootContext->setContextProperty("istep", m_interface);
}

void SerialCapture::updateCenter() {
    auto shift = m_interface->setTopLeft(currentCoord());
    flushCommand();
    blockStream();
	auto mv = [this]() { m_navigator->moveTo(m_interface->indexToCoord(QPoint(0, 0))); };
	QTimer::singleShot(100, mv);
    m_model->shiftData(shift);
}

void SerialCapture::setFocus(bool focus) {
    if (m_focus != focus) {
        m_focus = focus;
        emit focusChanged(focus);
    }
}

void SerialCapture::blockStream() {
    m_block = true;
    emit blockChanged(true);
}

void SerialCapture::unblockStream() {
    m_block = false;
    emit blockChanged(false);
}

QPoint SerialCapture::currentIndex() {
    return m_interface->coordToIndex(currentCoord());
}

QPointF SerialCapture::currentCoord() {
    return m_navigator->xy();
}

void SerialCapture::redirectImage(const QImage& img) {
    if (!m_block && m_focus)
        m_model->updateBuffer(img, currentIndex());
}

QSize SerialCapture::cellSize() const {
	return m_size;
}

void SerialCapture::setCellSize(const QSize& size) {
	if (m_size != size) {
		m_size = size;
		emit cellSizeChanged(m_size);
	}
}

void SerialCapture::zoomIn() {
	if (m_zoom > 1) {
		--m_zoom;
        auto sz = m_camera->size();
        sz /= m_zoom;
        setCellSize(sz);
	}
}

void SerialCapture::zoomOut() {
    if (m_zoom < 20) {
        ++m_zoom;
        auto sz = m_camera->size();
        sz /= m_zoom;
        setCellSize(sz);
    }
}

void SerialCapture::moveToSelected() {
    flushCommand();
	auto cmd = [=]() {
		blockStream();
		connect(m_navigator, &StepperNavigator::bufferFull, this, &SerialCapture::nextCommand);
		QTimer::singleShot(100, [=]() { m_navigator->moveTo(m_interface->indexToCoord(m_model->selectedCell())); });
	};
	QTimer::singleShot(100, cmd);
}

void SerialCapture::procSelect(const QPoint &pos) {
    m_model->clearSelection();
    int col = pos.x() / m_size.width();
    int row = pos.y() / m_size.height();
    m_model->select(QPoint(col, row));
}

void SerialCapture::procHighlight(const QPoint &pos) {
    int col = pos.x() / m_size.width();
    int row = pos.y() / m_size.height();
    QPoint index{ col, row };
    if (index != lastHighlight) {
        m_model->unhighlight();
        m_model->highlight(QPoint(col, row));
        lastHighlight = index;
    }
}

void SerialCapture::beginMultiSelect(const QPoint &pos) {
    int col = pos.x() / m_size.width();
    int row = pos.y() / m_size.height();
    select1 = QPoint(col, row);
}

void SerialCapture::endMultiSelect(const QPoint &pos) {
    m_model->clearSelection();
    int col = pos.x() / m_size.width();
    int row = pos.y() / m_size.height();
    auto select2 = QPoint(col, row);
    int tlx = (select1.x() < select2.x()) ? select1.x() : select2.x();
    int tly = (select1.y() < select2.y()) ? select1.y() : select2.y();
    int brx = (select1.x() > select2.x()) ? select1.x() : select2.x();
    int bry = (select1.y() > select2.y()) ? select1.y() : select2.y();
    m_model->multiselect(QPoint(tlx, tly), QPoint(brx, bry));
    selectCounter = m_model->selectedCount();
    emit selectCounterChanged(selectCounter);
}

void SerialCapture::boxFill() {
    flushCommand();
    auto ts = m_model->boxFill();
    vector<QPointF> targets;
    for (const auto& t : ts)
		targets.push_back(m_interface->indexToCoord(t));
	addBlockCommand(500);
    for (auto f : targets) {
        addMoveToCommand(f);
        addBlockCommand(500);
    }
    nextCommand();
}

void SerialCapture::autoFill() {
    flushCommand();
    auto ts = m_model->autoFill();
    if (ts.empty()) {
        emit autoFillFailed();
        return;
    }
    vector<QPointF> targets;
    for (const auto& t : ts)
        targets.push_back(m_interface->indexToCoord(t));
	addBlockCommand(500);
    for (auto f : targets) {
        addMoveToCommand(f);
        addBlockCommand(500);
    }
    nextCommand();
}

void SerialCapture::shiftUp() {
	flushCommand();
    blockStream();
    auto shift = m_interface->shiftOffset(QSize(0, -1));
    m_model->shiftData(shift);
}

void SerialCapture::shiftDown() {
	flushCommand();
    blockStream();
    auto shift = m_interface->shiftOffset(QSize(0, 1));
    m_model->shiftData(shift);
}

void SerialCapture::shiftRight() {
	flushCommand();
    blockStream();
    auto shift = m_interface->shiftOffset(QSize(1, 0));
    m_model->shiftData(shift);
}

void SerialCapture::shiftLeft() {
	flushCommand();
    blockStream();
    auto shift = m_interface->shiftOffset(QSize(-1, 0));
    m_model->shiftData(shift);
}

void SerialCapture::addCommand(Command cmd) {
    commandPool.push(cmd);
}

void SerialCapture::addMoveToCommand(const QPointF &target) {
    addCommand([=]() {
        blockStream();
        connect(m_navigator, &StepperNavigator::bufferFull, this, &SerialCapture::nextCommand);
		QTimer::singleShot(100, [=]() { m_navigator->moveTo(target); });
    });
}

void SerialCapture::addBlockCommand(int msecond) {
    auto cmd = [=]() {
        QTimer::singleShot(msecond, this, SLOT(nextCommand()));
    };
    addCommand(cmd);
}

void SerialCapture::nextCommand() {
    disconnect(m_navigator, &StepperNavigator::bufferFull, this, &SerialCapture::nextCommand);
    if (!commandPool.empty()) {
        auto cmd = commandPool.front();
        cmd();
        commandPool.pop();
    }
}

void SerialCapture::flushCommand() {
    disconnect(m_navigator, &StepperNavigator::bufferFull, this, &SerialCapture::nextCommand);
    m_navigator->stop();
    while (!commandPool.empty())
        commandPool.pop();
}





