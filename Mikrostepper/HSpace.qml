import QtQuick 2.3
import QtQuick.Controls 1.2

Item {
    id: root
    property int length: h2.x - h1.x
    property real realLength
    property int _index: cbUnit.currentIndex
    property alias _tlength: tLength.text
//    anchors.fill: parent

    function getRealLength() {
        var mod = 0
        switch(_index) {
        case 0:
            mod = 1
            break
        case 1:
            mod = 1000
            break
        case 2:
            mod = 10000
            break
        default:
            mod = 1
            break
        }
        var txt = parseInt(tLength.text)
        return mod * txt
    }

    Connections {
        target: appsettings
        onProfileIdChanged: updateProfile()
    }
    onVisibleChanged: updateProfile()

    LineWidget {
        id: h1
        orientation: 1
        x: parent.width/2 - 60
        min: 20
        max: h2.x - 20
    }
    LineWidget {
        id: h2
        orientation: 1
        x: parent.width/2 + 60
        min: h1.x + 20
        max: parent.width - 20
    }
    Rectangle {
        id: hOrnament
        color: "#0500ff00"
        height: parent.height
        anchors.left: h1.right
        anchors.right: h2.left
        Item {
            width: cbUnit.width + tLength.width + 10
            height: cbUnit.height
            anchors {
                bottom: parent.bottom; bottomMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            Row {
                spacing: 5
                TextField {
                    id: tLength
                    horizontalAlignment: Text.AlignRight
                    width: 60
                    font.pointSize: 10
                    text: "100"
                    validator: IntValidator { }
                    onTextChanged: realLength = getRealLength()
                    onFocusChanged: realLength = getRealLength()
                }
                ComboBox {
                    id: cbUnit
                    width: 55
                    onCurrentIndexChanged: realLength = getRealLength()
                    model: [ "μm", "mm", "cm" ]
                    currentIndex: 0
                }
            }
        }
    }
}
