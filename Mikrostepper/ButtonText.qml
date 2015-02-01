import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Button {
    property color textDefault: "#2c3e50"
    property color textDisabled: "#bdc3c7"
    property color textUnchecked: "#95a5a6"
    property int fontSize: 10
    property int textAlignment: Text.AlignHCenter
    property bool limitText: false
    property bool limitSize: false

    property color _currentColor: textDefault
    property color _hoverColor: Qt.lighter(_currentColor, 1.5)
    property real _width: 100

    width: _width

    style: ButtonStyle {
        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 25
            width: control.width
            border.width: 0
            color: "transparent"
        }
        label: TextRegular {
            text: control.text
            clip: limitText
            horizontalAlignment: textAlignment
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.pointSize: fontSize
            color: (control.enabled & control.hovered) ? _hoverColor : _currentColor
            onTextChanged: {
                if (!limitSize)
                    _width = (font.pixelSize * text.length > 100) ? font.pixelSize * text.length + 10 : 100
            }
        }
    }

    onCheckableChanged: {
        if (checkable) {
            _currentColor = Qt.binding(function() { return checked ? textDefault : textUnchecked } )
            _hoverColor = Qt.binding(function() { return checked ? Qt.lighter(textDefault, 1.5) :
                                                                   Qt.darker(textUnchecked, 1.5) } )
        }
        else {
            _currentColor = textDefault
            _hoverColor = Qt.lighter(_currentColor, 1.5)
        }
    }
    onEnabledChanged: {
        _currentColor = (enabled) ? textDefault : textDisabled
    }
}
