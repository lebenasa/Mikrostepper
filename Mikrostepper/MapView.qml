import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QuickCam 1.0

Rectangle {
    width: 1280
    height: 720

    Connections {
        target: appsettings
        onProfileIdChanged: atlas.initSettings()
        onProfileUpdated: atlas.initSettings()
        onSettingsChanged: atlas.initSettings()
    }

    ScrollView {
        id: scrollview
        anchors.fill: parent
        clip: true
        Rectangle {
            id: canvasarea
            width: (canvas.width > scrollview.width) ? canvas.width : scrollview.width
            height: (canvas.height > scrollview.height) ? canvas.height : scrollview.height
            color: "#34495e"
            Rectangle {
                id: canvas
                width: atlas.planeSize.width
                height: atlas.planeSize.height
                anchors.centerIn: parent
                color: "#2c3e50"

                Rectangle {
                    id: capturearea
                    color: "transparent"
                    x: atlas.captureRect.x - 13; y: atlas.captureRect.y - 13
                    width: atlas.captureRect.width + 26; height: atlas.captureRect.height + 26
                    visible: (atlas.captureRect.width > 1 && atlas.captureRect.height > 1)
                    border.color: "#9b59b6"
                    border.width: 2
                    SequentialAnimation {
                        id: blink2
                        ColorAnimation {
                            target: capturearea
                            properties: "border.color"
                            from: "#c0392b"
                            to: "#ecf0f1"
                            duration: 500
                        }
                        ColorAnimation {
                            target: capturearea
                            properties: "border.color"
                            from: "#ecf0f1"
                            to: "#c0392b"
                            duration: 500
                        }
                        loops: Animation.Infinite
                    }

                    Component.onCompleted: blink2.start()
                }

                Rectangle {
                    id: curpos
                    x: atlas.currentPos.x - 10; y: atlas.currentPos.y - 10
                    width: 20; height: 20
                    color: "transparent"
                    border.width: 5
                    border.color: "#c0392b"
                    radius: 60

                    SequentialAnimation {
                        id: blink
                        ColorAnimation {
                            target: curpos
                            properties: "border.color"
                            from: "#c0392b"
                            to: "#ecf0f1"
                            duration: 500
                        }
                        ColorAnimation {
                            target: curpos
                            properties: "border.color"
                            from: "#ecf0f1"
                            to: "#c0392b"
                            duration: 500
                        }
                        loops: Animation.Infinite
                    }

                    Component.onCompleted: blink.start()
                }

                Rectangle {
                    id: mark1
                    width: 26; height: 26
                    color: "#e74c3c"
                    visible: false
                    radius: 60
                    TextBlack {
                        anchors.centerIn: parent
                        text: "1"
                        font.pointSize: 11
                    }
                }
                Rectangle {
                    id: mark2
                    width: 26; height: 26
                    color: "#3498db"
                    visible: false
                    radius: 60
                    TextBlack {
                        anchors.centerIn: parent
                        text: "2"
                        font.pointSize: 11
                    }
                }
                Rectangle {
                    id: mark3
                    width: 26; height: 26
                    color: "#2ecc71"
                    visible: false
                    radius: 60
                    TextBlack {
                        anchors.centerIn: parent
                        text: "3"
                        font.pointSize: 11
                    }
                }
                Rectangle {
                    id: mark4
                    width: 26; height: 26
                    color: "#f1c40f"
                    visible: false
                    radius: 60
                    TextBlack {
                        anchors.centerIn: parent
                        text: "4"
                        font.pointSize: 11
                    }
                }

                MouseArea {
                    id: macanvas
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.CrossCursor
                    propagateComposedEvents: true
                    onClicked: {
                        if (mouse.button == Qt.RightButton) {
                            popMenu.x = mouse.x; popMenu.y = mouse.y
                            popMenu.visible = true
                        }
                        else
                            popMenu.visible = false
                    }
                    onCanceled: popMenu.visible = false
                }

                Rectangle {
                    id: popMenu
                    width: 100
                    height: 25
                    visible: false
                    Column {
                        ButtonSimple { id: btnMvHr
                            text: "Move Here"
                            onClicked: {
                                atlas.moveToPixel(popMenu.x, popMenu.y)
                                popMenu.visible = false }
                        }
                    }
                }
            }
        }
    }

    function popMark1() {
        mark1.x = atlas.currentPos.x - 13; mark1.y = atlas.currentPos.y - 13
        mark1.visible = true
    }
    function popMark2() {
        mark2.x = atlas.currentPos.x - 13; mark2.y = atlas.currentPos.y - 13
        mark2.visible = true
    }
    function popMark3() {
        mark3.x = atlas.currentPos.x - 13; mark3.y = atlas.currentPos.y - 13
        mark3.visible = true
    }
    function popMark4() {
        mark4.x = atlas.currentPos.x - 13; mark4.y = atlas.currentPos.y - 13
        mark4.visible = true
    }
    function hideAllMark() {
        mark1.visible = false
        mark2.visible = false
        mark3.visible = false
        mark4.visible = false
    }

    Rectangle {
        id: preview
        x: parent.width - width - 50
        y: 20
        width: 240
        height: 215

        Rectangle {
            id: rectangle1
            height: 25
            color: "#95a5a6"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left

            MouseArea {
                id: mouseArea1
                anchors.fill: parent
                drag.target: preview
                drag.axis: Drag.XAndYAxis
                drag.minimumX: 0
                drag.maximumX: scrollview.width - preview.width - 20
                drag.minimumY: 0
                drag.maximumY: scrollview.height - preview.height - 20
            }

            TextRegular {
                id: textRegular1
                text: "Camera View"
                anchors.fill: parent
                anchors.topMargin: 5
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 10
                color: "#2c3e50"
            }
        }

        Rectangle {
            id: bg
            anchors {
                top: rectangle1.bottom; bottom: parent.bottom
                left: parent.left; right: parent.right
            }

            function updateAspectRatio() {
                viewer.offsetSize = optilab.calculateAspectRatio(bg.width, bg.height)
            }

            onWidthChanged: updateAspectRatio()
            onHeightChanged: updateAspectRatio()

            MouseArea {
                id: maresize
                anchors.fill: parent
                property bool resizing: false
                property int resizeCode: 0
                hoverEnabled: true
                cursorShape: {
                    var shape = procMouseCursor()
                    if (shape === Qt.SizeHorCursor + 128) return Qt.SizeHorCursor
                    else return shape
                }
                onPressed: {
                    resizeCode = procMouseCursor()
                    resizing = true
                }
                onReleased: resizing = false
                onPositionChanged: {
                    if (resizing) {
                        procResize()
                    }
                }
                function procMouseCursor() {
                    if (mouseX <= 3 && mouseY >= parent.height - 3)
                        return Qt.SizeBDiagCursor
                    else if (mouseX >= parent.width - 3 && mouseY >= parent.height - 3)
                        return Qt.SizeFDiagCursor
                    else if (mouseX <= 3 && mouseY < parent.height)
                        return Qt.SizeHorCursor
                    else if (mouseX >= parent.width - 3 && mouseY < parent.height)
                        return Qt.SizeHorCursor + 128
                    else if (mouseX > 0 && mouseY >= parent.height - 3)
                        return Qt.SizeVerCursor
                    else
                        return Qt.ArrowCursor
                }
                property point lastXY: Qt.point(preview.x, preview.height)
                function resizeAlg(code) {
                    var xy = mapToItem(null, mouseX, mouseY)
                    var nw = preview.width + (lastXY.x - xy.x)
                    var nh = preview.height + (xy.y - lastXY.y)
                    if (code === Qt.SizeBDiagCursor) {
                        preview.x = (nw < 640 && nw > 240) ? xy.x : preview.x
                        preview.width = (nw < 640 && nw > 240) ? nw : preview.width
                        preview.height = (nh < 480 && nh > 215) ? nh : preview.height
                    }
                    else if (code === Qt.SizeFDiagCursor) {
                        nw = preview.width + (xy.x - lastXY.x)
                        nh = preview.height + (xy.y - lastXY.y)
                        preview.width = (nw < 640 && nw > 240) ? nw : preview.width
                        preview.height = (nh < 480 && nh > 215) ? nh : preview.height
                    }
                    else if (code === Qt.SizeHorCursor) {
                        preview.x = (nw < 640 && nw > 240) ? xy.x : preview.x
                        preview.width = (nw < 640 && nw > 240) ? nw : preview.width
                    }
                    else if (code === Qt.SizeHorCursor + 128) {
                        nw = preview.width + (xy.x - lastXY.x)
                        var ox = preview.x
                        preview.width = (nw < 640 && nw > 240) ? nw : preview.width
                        preview.x = ox
                    }
                    else if (code === Qt.SizeVerCursor) {
                        preview.height = (nh < 480 && nh > 215) ? nh : preview.height
                    }
                    lastXY = Qt.point(xy.x, xy.y)
                }
                function procResize() {
                    resizeAlg(resizeCode)
                }
            }

            Connections {
                target: camera
                onFrameReady: viewer.source = frame
            }

            CameraItem {
                id: viewer
                property size offsetSize : parent.updateAspectRatio()
                antialiasing: true
                anchors.fill: parent
                anchors {
                    leftMargin: offsetSize.width; rightMargin: offsetSize.width
                    topMargin: offsetSize.height; bottomMargin: offsetSize.height
                }
            }
        }
    }
}

