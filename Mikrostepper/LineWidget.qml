import QtQuick 2.3

Rectangle {
    id: root
    property int orientation: 0 //0 horizontal line, else vertical line
    property int min: 0
    property int max: 700
    width: orientation == 0 ? parent.width : 1
    height: orientation == 0 ? 1 : parent.height
    color: "green"

    MouseArea {
        id: ctrl
        anchors.fill: parent
        anchors.leftMargin: orientation == 0 ? 0 : -1
        anchors.rightMargin: orientation == 0 ? 0 : -1
        anchors.topMargin: orientation == 0 ? -1 : 0
        anchors.bottomMargin: orientation == 0 ? -1 : 0
        cursorShape: orientation == 0 ? Qt.SizeVerCursor : Qt.SizeHorCursor
        drag.target: root
        drag.axis: orientation == 0 ? Drag.YAxis : Drag.XAxis
        drag.minimumX: min
        drag.minimumY: min
        drag.maximumX: max
        drag.maximumY: max
    }
}
