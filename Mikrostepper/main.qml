import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import Leben.Asa 1.0

LebenWindow {
    id: applicationWindow1
    visible: true
    width: 1280
    height: 720
    title: qsTr("Mikrostepper")
//    x: (Screen.width - width) / 2
//    y: (Screen.height - height) / 2

    Item {
        id: base
        anchors.fill: parent
        Rectangle {
            id: titleBar
            height: 25
            color: "white"
            anchors {
                right: parent.right; left: parent.left; top: parent.top
            }
            z: 90
            RowLayout {
                anchors.fill: parent
                TextRegular {
                    id: title
                    Layout.fillWidth: true
                    text: "MICONOS MIKROSTEPPER"
                    font.pointSize: 10
                    font.letterSpacing: 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "#2c3e50"
                }
                ToolButton {
                    id: minimizeBtn
                    iconSource: hovered ? "Images/MinimizeHover.png" : "Images/Minimize.png"
                    onClicked: applicationWindow1.showMinimized()
                }
                ToolButton {
                    id: maximizeBtn
                    iconSource: {
                        if (applicationWindow1.visibility == Window.Maximized)
                            hovered ? "Images/RestoreHover.png" : "Images/Restore.png"
                        else
                            hovered ? "Images/MaximizeHover.png" : "Images/Maximize.png"
                    }
                    onClicked: {
                        if (applicationWindow1.visibility == Window.Maximized)
                            applicationWindow1.showNormal()
                        else
                            applicationWindow1.showMaximized()
                    }
                }
                ToolButton {
                    id: closeBtn
                    iconSource: hovered ? "Images/CloseHover.png" : "Images/Close.png"
                    onClicked: Qt.quit()
                }
            }
        }
        MainForm {
            id: mainForm
            anchors {
                right: parent.right; left: parent.left
                top: titleBar.bottom; bottom: parent.bottom
                topMargin: 5
            }
        }
    }



    Component.onCompleted: {
        applicationWindow1.showMaximized()
    }
}
