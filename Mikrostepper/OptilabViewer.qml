import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QuickCam 1.0

Rectangle {
    id: bg
    width: 1280
    height: 720
    color: "#34495e"
    border.width: 0
    focus: visible
    property bool calibrationSwitch: false

    property alias pixelWidth : hspacer.length
    property alias pixelHeight: vspacer.length
    property alias realWidth: hspacer.realLength
    property alias realHeight: vspacer.realLength
    property alias screenWidth: viewer.width
    property alias screenHeight: viewer.height

    property real profileWidth
    property real profileHeight

    function updateAspectRatio() {
        viewer.offsetSize = optilab.calculateAspectRatio(bg.width, bg.height)
    }

    onWidthChanged: updateAspectRatio()
    onHeightChanged: updateAspectRatio()

    Connections {
        target: camera
        onFrameReady: viewer.source = frame
    }

    Connections {
        target: appsettings
        onProfileIdChanged: updateProfile()
    }

    function updateProfile() {
        profileWidth = appsettings.readProfileWidth(appsettings.profileId)
        profileHeight = appsettings.readProfileHeight(appsettings.profileId)
    }

    function updateCalibrationText() {
        var twidth = (pixelWidth / screenWidth) * profileWidth
        var theight = (pixelHeight / screenHeight) * profileHeight
        hspacer._tlength = Math.round(twidth)
        vspacer._tlength = Math.round(theight)
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

        HSpace {
            id: hspacer
            anchors.fill: parent
            visible: calibrationSwitch
            onLengthChanged: updateCalibrationText()
        }

        VSpace {
            id: vspacer
            anchors.fill: parent
            visible: calibrationSwitch
            onLengthChanged: updateCalibrationText()
        }

        Rectangle {
            id: focus
            width: parent.width * 0.5; height: parent.height * 0.5;
            anchors.centerIn: parent
            border.width: 2
            border.color: "yellow"
            color: "transparent"
            visible: false
        }

        BookmarkMenu {
            id: bookmarkmenu
        }

        MouseArea {
            id: mafocus
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button == Qt.LeftButton) {
                    focus.visible = true
                    autofocus.scanSearch()
                }
                else if (mouse.button == Qt.RightButton) {
                    bookmarkmenu.popup()
                }
            }
        }

        Connections {
            target: autofocus
            onFocusFound: {
                focus.border.color = "lime"
                timerfocus.start()
            }
        }

        Timer {
            id: timerfocus
            interval: 500
            onTriggered: {
                focus.visible = false
                focus.border.color = "yellow"
            }
        }
    }
}

