import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0

Button {
    id: root
    property color bgdefault: "transparent"
    property color bgchecked: "#3498db"
    property color bgpressed: "#2980b9"
    property color bordercolor: "#3498db"
    property color textcolor: "#2c3e50"
    style: ButtonStyle {
        background: Rectangle {
            implicitWidth: 60
            implicitHeight: 80
            color: control.pressed ? bgpressed : control.checked ? bgchecked : bgdefault
            border.width: control.hovered ? 1 : 0
            border.color: bordercolor
            radius: 4
        }
        label: Item {
            anchors.fill: parent
            Image {
                id: icon
                anchors {
                    left: parent.left; right: parent.right
                    top: parent.top
                }
                sourceSize.width: 60
                sourceSize.height: 50
                source: control.iconSource
                smooth: true
                fillMode: Image.PreserveAspectFit
                visible: false
            }
            Desaturate {
                id: desaturate
                anchors.fill: icon
                source: icon
                desaturation: control.enabled ? 0.0 : 0.75
            }
            TextRegular {
                width: 60
                text: control.text
                anchors {
                    horizontalCenter: icon.horizontalCenter
                    bottom: parent.bottom
                }
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 9
                wrapMode: Text.WordWrap
                color: control.enabled ? textcolor : "#95a5a6"
            }
        }
    }
}
