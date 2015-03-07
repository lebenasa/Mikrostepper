import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QuickCam 1.0

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#34495e"

    function shiftUp() {
        serialcapture.shiftUp()
    }
    function shiftDown() {
        serialcapture.shiftDown()
    }
    function shiftRight() {
        serialcapture.shiftRight()
    }
    function shiftLeft() {
        serialcapture.shiftLeft()
    }

    function updateSettings() {
        cammodel.clearBuffers()
        serialcapture.flushCommand()
        istep.initSettings()
        cammodel.clearBuffers()
        if (root.visible) serialcapture.updateCenter()
    }

    Connections {
        target: appsettings
        onProfileIdChanged: updateSettings()
        onProfileUpdated: updateSettings()
        onSettingsChanged: updateSettings()
    }

    ScrollView {
        id: gridview
        anchors.fill: parent
        clip: true
        Item {
            width: (gridarea.width > gridview.width) ? gridarea.width : gridview.width
            height: (gridarea.height > gridview.height) ? gridarea.height : gridview.height
            Item {
                id: gridarea
                anchors.centerIn: parent
                width: innergridarea.width + shiftright.width + shiftleft.width
                height: innergridarea.height + shiftdown.height + shiftup.height
                ToolButton {
                    id: shiftup
                    anchors {
                        bottom: innergridarea.top; left: innergridarea.left; right: innergridarea.right
                    }
                    iconSource: "Images/ArrowSmall.png"
                    onClicked: shiftUp()
                }
                ToolButton {
                    id: shiftdown
                    anchors {
                        top: innergridarea.bottom; left: innergridarea.left; right: innergridarea.right
                    }
                    iconSource: "Images/ArrowSmall.png"
                    rotation: 180
                    onClicked: shiftDown()
                }
                ToolButton {
                    id: shiftright
                    anchors {
                        left: innergridarea.right; top: innergridarea.top; bottom: innergridarea.bottom
                    }
                    iconSource: "Images/ArrowLSmall.png"
                    rotation: 180
                    onClicked: shiftRight()
                }
                ToolButton {
                    id: shiftleft
                    anchors {
                        right: innergridarea.left; top: innergridarea.top; bottom: innergridarea.bottom
                    }
                    iconSource: "Images/ArrowLSmall.png"
                    onClicked: shiftLeft()
                }

                Rectangle {
                    id: innergridarea
                    color: "#34495e"
                    width: serialcapture.cellSize.width * cammodel.cols
                    height: serialcapture.cellSize.height * cammodel.rows
                    anchors.centerIn: parent
                    Grid {
                        anchors.fill: parent
                        columns: cammodel.cols
                        Repeater {
                            id: cameraGrid
                            model: cammodel
                            delegate: Rectangle {
                                id: delegateBorder
                                width: serialcapture.cellSize.width
                                height: serialcapture.cellSize.height
                                color: "transparent"
                                border.width: (selected | highlight) ? 2 : 1
                                border.color: selected ? "yellow" : highlight ? "magenta" : "#34495e"
                                CameraItem {
                                    id: cameraDelegate
                                    anchors.fill: parent
                                    anchors.margins: (selected | highlight) ? 2 : 1
                                    blocked: false
                                    source: buffer
                                    renderParams: CameraItem.ScaledToItem
                                    overlap: istep.overlap()
                                }
                                Behavior on width { NumberAnimation { duration: 200 } }
                                Behavior on height { NumberAnimation { duration: 200 } }
                            }
                        }
                    }
                    MouseArea {
                        id: cameraMouse
                        anchors.fill: parent
                        anchors.margins: 5
                        hoverEnabled: true
                        property int mousecount: 0
                        onPositionChanged: {
                            if (mousecount === 10) {
                                if (cameraMouse.containsPress)
                                    serialcapture.endMultiSelect(Qt.point(mouse.x, mouse.y))
                                else if (cameraMouse.containsMouse)
                                    serialcapture.procHighlight(Qt.point(mouse.x, mouse.y))
                                mousecount = 0
                            }
                            ++mousecount
                        }
                        //                onClicked: serialcapture.procSelect(Qt.point(mouse.x, mouse.y))
                        onPressed: serialcapture.beginMultiSelect(Qt.point(mouse.x, mouse.y))
                        onReleased: {
                            if (cameraMouse.containsMouse)serialcapture.endMultiSelect(Qt.point(mouse.x, mouse.y))
                        }
                    }
                }
            }
        }
        flickableItem.interactive: false
    }
}

