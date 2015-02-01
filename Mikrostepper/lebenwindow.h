#ifndef LEBENWINDOW_H
#define LEBENWINDOW_H

#include <QQuickWindow>
#include <QWindow>
#include "qt_windows.h"
#define QT_WA(unicode, ansi) unicode

class LebenWindow : public QQuickWindow
{
    Q_OBJECT
    enum class Style : DWORD
    {
        framed = (WS_OVERLAPPEDWINDOW | WS_THICKFRAME | WS_CLIPCHILDREN),
        frameless = (WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_THICKFRAME | WS_CLIPCHILDREN)
    };
public:
    LebenWindow(QWindow* parent = 0);
    ~LebenWindow();

private:
    long hittest(HWND hwnd, MSG* msg);
protected:
    bool nativeEvent(const QByteArray &eventType, void *message, long *result);
};

#endif // LEBENWINDOW_H
