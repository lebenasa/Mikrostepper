import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Rectangle {
    width: 480
    height: 320
    property alias profileModel: _model

    property real pixelWidth
    property real pixelHeight
    property real realWidth
    property real realHeight
    property real screenWidth
    property real screenHeight

    signal done

    Component.onCompleted: {
        var sz = appsettings.checkProfileCount()
        for (var i = 0; i < sz; ++i) {
            _model.append({ "name": appsettings.readProfileName(i),
                              "x": appsettings.readProfileWidth(i),
                              "y": appsettings.readProfileHeight(i)
                          })
        }
    }

    Dialog {
        id: dgadd
        width: 200
        height: 100
        title: "Add New Profile"
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        TextField { id: nameAdd }
        onAccepted: {
            _model.append({ "name": nameAdd.text, "x": 0, "y": 0 })
            nameAdd.text = ""
        }
    }

    Dialog {
        id: dgedit
        width: 200
        height: 100
        title: "Edit Profile Name"
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        TextField { id: nameEdit }
        onAccepted: {
            _model.setProperty(tableview.currentRow, "name", nameEdit.text)
        }
    }

    MessageDialog {
        id: warning
        title: "Warning"
        text: "Are you sure? This operation is not undoable."
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            if (appsettings.profileId == tableview.currentRow)
                appsettings.profileId = 0
            _model.remove(tableview.currentRow)
            appsettings.beginUpdateProfile()
            for (var i = 0; i < _model.count; ++i)
                appsettings.updateProfile(_model.get(i).name, _model.get(i).x, _model.get(i).y)
            appsettings.endUpdateProfile()
            tableview.selection.clear()
        }
    }

    MessageDialog {
        id: warning2
        title: "Warning"
        text: "Are you sure? This operation is not undoable."
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            appsettings.resetProfile()
            _model.clear()
            var sz = appsettings.checkProfileCount()
            for (var i = 0; i < sz; ++i) {
                _model.append({ "name": appsettings.readProfileName(i),
                                  "x": appsettings.readProfileWidth(i),
                                  "y": appsettings.readProfileHeight(i)
                              })
            }
            appsettings.setActiveProfileId(0)
            tableview.selection.clear()
        }
    }

    ListModel {
        id: _model
    }

    SplitView {
        id: splitView1
        anchors.fill: parent

        TableView {
            id: tableview
            width: 200
            height: 200
            TableViewColumn{ role: "name"  ; title: "Profile Name" ; width: 150 }
            TableViewColumn{ role: "x"  ; title: "Width (μm)" ; width: 100 }
            TableViewColumn{ role: "y"  ; title: "Height (μm)" ; width: 100 }
            model: _model
            Layout.fillWidth: true
            Layout.minimumWidth: 250
        }

        Rectangle {
            Layout.minimumWidth: 130
            ColumnLayout {
                id: columnLayout1
                anchors.fill: parent
                spacing: 10
                Item { id: item1; width: 82; height: 35; }

                Button {
                    id: buttonSave
                    text: "Save"
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: tableview.selection.count > 0
                    onClicked: {
                        console.log(pixelWidth)
                        console.log(pixelHeight)
                        console.log(realWidth)
                        console.log(realHeight)
                        _model.setProperty(tableview.currentRow, "x", screenWidth * (realWidth / pixelWidth))
                        _model.setProperty(tableview.currentRow, "y", screenHeight* (realHeight  / pixelHeight))
                        appsettings.beginUpdateProfile()
                        for (var i = 0; i < _model.count; ++i)
                            appsettings.updateProfile(_model.get(i).name, _model.get(i).x, _model.get(i).y)
                        appsettings.endUpdateProfile()
                        appsettings.profileId = tableview.currentRow
                        if (_model.count == 0)
                            appsettings.profileId = -1
                        done()
                    }
                }

                Item { id: item2; height: 22; Layout.fillHeight: true; }


                Button {
                    id: buttonAdd
                    text: "Add"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        dgadd.open()
                    }
                }

                Button {
                    id: buttonEdit
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Edit"
                    enabled: tableview.selection.count > 0
                    onClicked: {
                        nameEdit.text = _model.get(tableview.currentRow).name
                        nameEdit.selectAll()
                        dgedit.open()
                    }
                }

                Button {
                    id: buttonRemove
                    text: "Remove"
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: (tableview.selection.count > 0 && _model.count > 1)
                    onClicked: {
                        warning.open()
                    }
                }

                Button {
                    id: buttonReset
                    text: "Load Default"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        warning2.open()
                    }
                }

                Item { id: item3; height: 66 }
            }
        }
    }

}

