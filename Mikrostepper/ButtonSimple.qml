import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Button {
    property color bgdefault: "transparent"
    property color bgpressed: "transparent"
    property color bghovered: "#3498db"
    property color bordercolor: "#3498db"
    property color textcolor: "#2c3e50"
    property bool drawBorder: false
    property int fontSize: 10
    property int textAlignment: Text.AlignHCenter

    property real _width: 100

    width: _width

    style: ButtonStyle {
        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 25
            border.width: (drawBorder) ? 1 : control.hovered ? 1 : 0
            border.color: control.enabled ? bordercolor : "#bdc3c7"
            color: control.pressed ? bgpressed : control.hovered ? bghovered : "transparent"
        }
        label: TextRegular {
            text: control.text
            horizontalAlignment: textAlignment
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.pointSize: fontSize
            color: control.enabled ? textcolor : "#bdc3c7"
            onTextChanged: {
                _width = (contentWidth > 100) ? contentWidth + 10 : 100
            }
        }
    }
}
