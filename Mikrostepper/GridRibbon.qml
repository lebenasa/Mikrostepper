import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QuickCam 1.0

Rectangle {
    id: ribbonbar
    height: 120
    width: 720
    color: "#ecf0f1"

    function saveSelected() {
        if (!btnSaveSelected) return
        dgSaveSelected.open()
    }
    function saveAll() {
        dgSaveAll.open()
    }
    function moveToSelected() {
        if (!btnMove.enabled) return
        serialcapture.moveToSelected()
    }
    function fillSelected() {
        if (!btnFill.enabled) return
        serialcapture.boxFill()
    }
    function autoFill() {
        serialcapture.autoFill()
    }
    function clearSelected() {
        if (!btnClear.enabled) return
        cammodel.clearSelectedBuffers()
    }
    function clearAll() {
        confirmclear.visible = true
    }
    function invertClear() {
        cammodel.invertSelection()
        cammodel.clearSelectedBuffers()
        cammodel.clearSelection()
    }
    function enlargeCells() {
        serialcapture.zoomIn()
    }
    function shrinkCells() {
        serialcapture.zoomOut()
    }

    Binding {
        target: serialcapture
        property: "focus"
        value: ribbonbar.visible
    }

    MessageDialog {
        id: warning
        title: "Not enough information for auto-fill"
        text: "Unable to perform auto-fill"
        informativeText: "Try to fill at least 2 cells by Move or Fill"
        detailedText: "Less than 2 cells are filled"
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: confirmclear
        title: "Confirm Clear All"
        text: "Are you sure?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: cammodel.clearBuffers()
    }

    BusyDialog {
        id: busy1
        Connections {
            target: cammodel
            onSaveCompleted: busy1.visible = false
        }
    }

    FileDialog {
        id: dgSaveSelected
        title: "Select Images Directory"
        selectFolder: true
        onAccepted: {
            busy1.visible = true
            cammodel.saveSelectedBuffers(folder)
        }
    }

    FileDialog {
        id: dgSaveAll
        title: "Select Images Directory"
        selectFolder: true
        onAccepted: {
            busy1.visible = true
            cammodel.saveBuffers(folder)
        }
    }

    Connections {
        target: serialcapture
        onAutoFillFailed: warning.visible = true
    }

    ButtonRibbon {
        id: btnSaveSelected
        text: "Save Selected"
        iconSource: "Images/SaveSelected.png"
        tooltip: "Save image in selected cells (indicated by yellow border)"
        anchors.verticalCenterOffset: -10
        anchors.left: btnSaveAll.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        enabled: (serialcapture.selectCounter > 0)
        onClicked: saveSelected()
    }

    ButtonRibbon {
        id: btnSaveAll
        text: "Save All"
        iconSource: "Images/SaveAll.png"
        tooltip: "Save all images in current view"
        enabled: true
        anchors.verticalCenterOffset: -10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        onClicked: saveAll()
    }

    Rectangle {
        id: rectangle1
        width: 2
        height: parent.height - 10
        color: "#bdc3c7"
        anchors.left: btnSaveSelected.right
        anchors.leftMargin: 10
        border.width: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    ButtonRibbon {
        id: btnMove
        text: "Move"
        iconSource: "Images/MoveToSelected.png"
        tooltip: "Move to selected cell (indicated by yellow border)"
        anchors.verticalCenterOffset: -10
        anchors.left: rectangle1.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        enabled: (serialcapture.selectCounter === 1)
        onClicked: moveToSelected()
    }

    ButtonRibbon {
        id: btnFill
        text: "Fill"
        iconSource: "Images/FillSelected.png"
        tooltip: "Start capture to fill selected cell with images"
        anchors.verticalCenterOffset: -10
        anchors.left: btnMove.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        enabled: (serialcapture.selectCounter > 1)
        onClicked: fillSelected()
    }

    ButtonRibbon {
        id: btnAutoFill
        text: "Auto-Fill"
        iconSource: "Images/FillAuto.png"
        tooltip: "Automatically fill cells based on existing images"
        anchors.verticalCenterOffset: -10
        anchors.left: btnFill.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        onClicked: autoFill()
    }

    ButtonSimple {
        id: btnClear
        text: "Clear"
        tooltip: "Clear selected cells"
        fontSize: 9
        anchors.verticalCenterOffset: -10
        anchors.left: btnAutoFill.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        enabled: (serialcapture.selectCounter > 0)
        onClicked: clearSelected()
    }

    ButtonSimple {
        id: btnClearAll
        text: "Clear All"
        tooltip: "Clear all images in current view"
        fontSize: 9
        anchors.top: btnClear.bottom
        anchors.topMargin: 4
        anchors.left: btnClear.left
        onClicked: clearAll()
    }

    ButtonSimple {
        id: btnInvert
        text: "Invert Clear"
        enabled: (serialcapture.selectCounter > 0)
        tooltip: "Clear all cells excluding selected cells"
        fontSize: 9
        anchors.bottom: btnClear.top
        anchors.bottomMargin: 4
        anchors.left: btnClear.left
        onClicked: invertClear()
    }

    Rectangle {
        id: rectangle2
        width: 2
        height: parent.height - 10
        color: "#bdc3c7"
        anchors.left: btnClear.right
        anchors.leftMargin: 10
        border.width: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    TextRegular {
        id: textRegular1
        color: "#2c3e50"
        text: "Command"
        font.pointSize: 9
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.right: rectangle2.left
        anchors.left: rectangle1.right
    }

    TextRegular {
        id: textRegular2
        color: "#2c3e50"
        text: "Save"
        anchors.bottomMargin: 5
        anchors.bottom: parent.bottom
        font.pointSize: 9
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.right: btnSaveSelected.right
        anchors.left: btnSaveAll.left
    }

    ButtonRibbon {
        id: btnZoomIn
        text: "Enlarge"
        iconSource: "Images/EnlargeGrid.png"
        tooltip: "Enlarge cell size"
        anchors.left: rectangle2.right
        anchors.leftMargin: 10
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        onClicked: enlargeCells()
    }

    ButtonRibbon {
        id: btnZoomOut
        text: "Shrink"
        iconSource: "Images/ShrinkGrid.png"
        tooltip: "Shrink cell size"
        anchors.left: btnZoomIn.right
        anchors.leftMargin: 10
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        onClicked: shrinkCells()
    }

    Rectangle {
        id: rectangle3
        width: 2
        height: parent.height - 10
        color: "#bdc3c7"
        anchors.left: btnZoomOut.right
        anchors.leftMargin: 10
        border.width: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    TextRegular {
        id: textRegular3
        y: 101
        color: "#2c3e50"
        text: "Cell Size"
        font.pointSize: 9
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.right: rectangle3.left
        anchors.left: rectangle2.right
    }
}
