import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

Dialog {
    title: qsTr("Application Busy")
    modality: Qt.ApplicationModal
//    flags: Qt.FramelessWindowHint
    width: 300
    height: 200
//    visible: true
    contentItem: Rectangle {
        id: rectangle1
        anchors.fill: parent
        border.width: 2
        border.color: "#444444"
        BusyIndicator {
            id: indicator
            anchors.horizontalCenterOffset: -parent.width/4;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.verticalCenter: parent.verticalCenter
        }

        TextRegular {
            id: textRegular1
            x: 116
            y: 94
            text: qsTr("Application is working.
Please wait. . .")
            anchors.leftMargin: 10
            font.pointSize: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: indicator.right
        }
    }
}
