import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

Rectangle {
    id: ribbonBar
    width: 720
    height: 120
    color: "#ecf0f1"

    signal requestSave

    ButtonRibbon {
        id: buttonRibbon1
        text: "Save Calibration"
        iconSource: "Images/SaveCalibration.png"
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            focus = true
            requestSave()
        }
    }

    Rectangle {
        id: rectangle1
        width: 2
        height: parent.height - 10
        color: "#bdc3c7"
        anchors.left: buttonRibbon1.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }
}

