import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

Rectangle {
    id: ribbonBar
    width: 720
    height: 120
    color: "#ecf0f1"
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: parent.left

    signal startCapture
    signal mark1Changed
    signal mark2Changed
    signal mark3Changed
    signal mark4Changed

    function capture() {
        if (!btnStartCapture.enabled) return
        dgApproximate.visible = true
    }

    MessageDialog {
        id: dgApproximate
        title: "Confirm capture"
        text: "%1x%2 frames. Approximately %3. Are you sure?".arg(atlas.approxSize.width).
        arg(atlas.approxSize.height).arg(atlas.approxTime)
        onAccepted: dgSaveDir.visible = true
    }

    FileDialog {
        id: dgSaveDir
        title: "Select Images Directory"
        selectFolder: true
        onAccepted: {
            startCapture()
            dgProgress.visible = true
            atlas.startCapture(folder)
        }
    }

    Dialog {
        id: dgProgress
        title: "Application is Working"
        modality: Qt.ApplicationModal
        standardButtons: StandardButton.Abort
        width: 600; height: 80
        onRejected: {
            atlas.flushCommand()
        }

        Rectangle {
            width: 600; height: 80
            ProgressBar {
                id: progressbar1
                width: 400
                anchors.centerIn: parent
                maximumValue: atlas.approxSize.width * atlas.approxSize.height
                minimumValue: 0
                value: atlas.progress
                onValueChanged: {
                    if (value == maximumValue) {
                        dgProgress.close()
                    }
                }
            }
            TextRegular {
                id: progresstext
                text: "Progress: %1/%2".arg(progressbar1.value).arg(progressbar1.maximumValue)
                anchors.left: progressbar1.left
                anchors.bottom: progressbar1.top; anchors.bottomMargin: 5
                font.pointSize: 9
            }
        }
    }

    ButtonRibbon {
        id: btnStartCapture
        y: 20
        text: "Start Capture"
        iconSource: "Images/MapCapture.png"
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        enabled: (atlas.approxSize.width * atlas.approxSize.height > 2)
        onClicked: capture()
    }

    Rectangle {
        id: rectangle1
        width: 2
        height: 110
        color: "#bdc3c7"
        anchors.left: btnStartCapture.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    ButtonRibbon {
        id: btnMark1
        text: "Mark as Point 1"
        iconSource: "Images/SelectPt1.png"
        anchors.leftMargin: 10
        anchors.left: rectangle1.right
        anchors.verticalCenter: btnStartCapture.verticalCenter
        onClicked: mark1Changed()
    }

    ButtonRibbon {
        id: btnMark2
        text: "Mark as Point 2"
        iconSource: "Images/SelectPt2.png"
        anchors.left: btnMark1.right
        anchors.leftMargin: 10
        anchors.verticalCenter: btnStartCapture.verticalCenter
        onClicked: mark2Changed()
    }

    ButtonRibbon {
        id: btnMark3
        text: "Mark as Point 3"
        iconSource: "Images/SelectPt3.png"
        anchors.left: btnMark2.right
        anchors.leftMargin: 10
        anchors.verticalCenter: btnStartCapture.verticalCenter
        onClicked: mark3Changed()
    }

    ButtonRibbon {
        id: btnMark4
        text: "Mark as Point 4"
        iconSource: "Images/SelectPt4.png"
        anchors.verticalCenter: btnStartCapture.verticalCenter
        anchors.left: btnMark3.right
        anchors.leftMargin: 10
        onClicked: mark4Changed()
    }

    Rectangle {
        id: rectangle2
        width: 2
        height: 110
        color: "#bdc3c7"
        anchors.left: btnMark4.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    TextRegular {
        id: textRegular1
        color: "#2c3e50"
        text: "Markers"
        font.pointSize: 9
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.right: rectangle2.left
        anchors.left: rectangle1.right
    }
}

