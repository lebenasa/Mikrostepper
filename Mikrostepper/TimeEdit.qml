import QtQuick 2.2
import QtQuick.Dialogs 1.2

Dialog {
    id: timeEdit
    property alias ht : hour.tens
    property alias ho : hour.ones
    property alias mt : minutes.tens
    property alias mo : minutes.ones
    property alias st : seconds.tens
    property alias so : seconds.ones
    width: 300
    height: 160
    visible: false
    title: "Set Time"
    modality: Qt.ApplicationModal

    function totalInterval() {
        return so + st * 10 + mo * 60 + mt * 10 * 60 + ho * 60 * 60 + ht * 10 * 60 * 60
    }

    function toInterval(total) {
        var hour = Math.floor(total / 3600)
        var minute = Math.floor((total - hour * 3600) / 60)
        var secs = Math.floor(total - (hour * 3600) - (minute * 60))
        ho = hour % 10
        ht = (hour - ht) / 10
        mo = minute % 10
        mt = (minute - mo) / 10
        so = secs % 10
        st = (secs - so) / 10
    }

    function addInterval() {
        var val = totalInterval() + 1
        toInterval(val)
    }

    function minInterval() {
        var val = totalInterval() - 1
        toInterval(val)
    }

    contentItem: Rectangle {
        width: 300
        height: 160
        Rectangle {
            id: frame
            color: "transparent"
            focus: true
            anchors.fill: parent
            border.width: 2
            Keys.onPressed: {
                if (event.key == Qt.Key_Enter) close()
            }
            MouseArea {
                anchors.fill: parent
                onClicked: frame.focus = true
            }
        }

        TimeInput {
            id: hour
            anchors {
                right: separator1.left
                verticalCenter: minutes.verticalCenter
            }
            onNextFocus: seconds.focus = true
            onEnterPressed: close()
        }


        Text {
            id: separator1
            anchors {
                right: minutes.left
                verticalCenter: minutes.verticalCenter
            }
            verticalAlignment: Text.AlignVCenter
            font.family: "Segoe UI"
            font.weight: Font.DemiBold
            font.pointSize: 32
            color: "#555"
            text: ":"
        }
        TimeInput {
            id: minutes
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter; verticalCenterOffset: -15
            }
            timeType: "min"
            onNextFocus: hour.focus = true
            onEnterPressed: close()
        }
        Text {
            id: separator2
            anchors {
                left: minutes.right
                verticalCenter: minutes.verticalCenter
            }
            verticalAlignment: Text.AlignVCenter
            font.family: "Segoe UI"
            font.weight: Font.DemiBold
            font.pointSize: 32
            color: "#555"
            text: ":"
        }
        TimeInput {
            id: seconds
            anchors {
                left: separator2.right
                verticalCenter: minutes.verticalCenter
            }
            timeType: "sec"
            onNextFocus: minutes.focus = true
            onEnterPressed: close()
        }

        ButtonSimple {
            id: okButton
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom; bottomMargin: 20
            }
            text: "OK"
            onClicked: close()
            drawBorder: true
        }
    }

    onVisibilityChanged: {
        if (visible) seconds.focus = true
    }
}
