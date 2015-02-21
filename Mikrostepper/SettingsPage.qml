import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.0
import QuickCam 1.0

Rectangle {
    id: root
    property alias keysModel: _model
    property bool requireRestart: false
    width: 800
    height: 600

    function initSettings() {
        for (var d = 0; d < doublesettings.count; ++d) {
            var val = appsettings.readDouble(doublesettings.get(d).name, doublesettings.get(d).defval)
            doublesettings.set(d, { "value": val })
        }

        for (var b = 0; b < booleansettings.count; ++b) {
            var bval = appsettings.readBool(booleansettings.get(b).name, booleansettings.get(b).defval)
            booleansettings.set(b, { "value": bval })
        }

        for (var j = 0; j < integersettings.count; ++j) {
            var ival = appsettings.readInt(integersettings.get(j).name, integersettings.get(j).defval)
            integersettings.set(j, { "value": ival })
        }

        for (var i = 0; i < _model.count; ++i) {
            var key = appsettings.readShortcut(_model.get(i).name, _model.get(i).keys)
            _model.set(i, { "shortcut": key })
        }
    }

    function updateSettings() {
        for (var d = 0; d < doublesettings.count; ++d) {
            var val = appsettings.readDouble(doublesettings.get(d).name, doublesettings.get(d).defval)
            if (val !== doublesettings.get(d).value)
                appsettings.saveSettings(doublesettings.get(d).name, doublesettings.get(d).value)
        }

        for (var b = 0; b < booleansettings.count; ++b) {
            var bval = appsettings.readBool(booleansettings.get(b).name, booleansettings.get(b).defval)
            if (bval !== booleansettings.get(b).value)
                appsettings.saveSettings(booleansettings.get(b).name, booleansettings.get(b).value)
        }

        for (var j = 0; j < integersettings.count; ++j) {
            var ival = appsettings.readInt(integersettings.get(j).name, integersettings.get(j).defval)
            if (ival !== integersettings.get(j).value)
                appsettings.saveSettings(integersettings.get(j).name, integersettings.get(j).value)
        }

        for (var i = 0; i < _model.count; ++i) {
            var key = appsettings.readShortcut(_model.get(i).name, _model.get(i).keys)
            if (key !== _model.get(i).shortcut)
                appsettings.saveShortcut(_model.get(i).name, _model.get(i).shortcut)
        }

        if (stepperunitx.value !== appsettings.readCNCStepsPerUnitX()) {
            appsettings.saveSettings("StepPerUnitX", stepperunitx.value)
            requireRestart = true
        }
        if (stepperunity.value !== appsettings.readCNCStepsPerUnitY()) {
            appsettings.saveSettings("StepPerUnitY", stepperunity.value)
            requireRestart = true
        }
        if (stepperunitz.value !== appsettings.readCNCStepsPerUnitZ()) {
            appsettings.saveSettings("StepPerUnitZ", stepperunitz.value)
            requireRestart = true
        }
    }

    function restoreSettings() {
        for (var d = 0; d < doublesettings.count; ++d) {
            var val = appsettings.readDouble(doublesettings.get(d).name, doublesettings.get(d).defval)
            if (val !== doublesettings.get(d).defval)
                appsettings.eraseSettings(doublesettings.get(d).name)
        }

        for (var b = 0; b < booleansettings.count; ++b) {
            var bval = appsettings.readBool(booleansettings.get(b).name, booleansettings.get(b).defval)
            if (val !== booleansettings.get(b).defval)
                appsettings.eraseSettings(booleansettings.get(b).name)
        }

        for (var j = 0; j < integersettings.count; ++j) {
            var ival = appsettings.readInt(integersettings.get(j).name, integersettings.get(j).defval)
            if (val !== integersettings.get(j).defval)
                appsettings.eraseSettings(integersettings.get(j).name)
        }

        for (var i = 0; i < _model.count; ++i) {
            var key = appsettings.readShortcut(_model.get(i).name, _model.get(i).keys)
            if (key !== _model.get(i).keys)
                appsettings.resetShortcut(_model.get(i).name)
        }

        if (5096.0 !== appsettings.readCNCStepsPerUnitX()) {
            stepperunitx.value = 5096.0
            appsettings.saveSettings("StepPerUnitX", 5096.0)
            requireRestart = true
        }
        if (5096.0 !== appsettings.readCNCStepsPerUnitY()) {
            stepperunity.value = 5096.0
            appsettings.saveSettings("StepPerUnitY", 5096.0)
            requireRestart = true
        }
        if (1067.0 !== appsettings.readCNCStepsPerUnitZ()) {
            stepperunitz.value = 1067.0
            appsettings.saveSettings("StepPerUnitZ", 1067.0)
            requireRestart = true
        }
    }

    function setZeroX() { stepper.setZeroX() }
    function setZeroY() { stepper.setZeroY() }
    function setZeroZ() { stepper.setZeroZ() }

    BusyDialog {
        id: initbusy
    }

    Connections {
        target: navigator
        onInitializeDone: initbusy.close()
    }

    RowLayout {
        id: rowLayout1
        spacing: 0
        anchors.fill: parent

        Rectangle {
            id: menu
            color: "#ecf0f1"
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            Layout.preferredWidth: 200
            ExclusiveGroup { id: group1 }
            ColumnLayout {
                id: rowLayout2
                anchors.fill: parent

                Item {
                    id: spacer2
                    Layout.minimumHeight: 50
                }

                ButtonText {
                    id: buttonText1
                    text: "Camera"
                    textDefault: "#000000"
                    checked: true
                    checkable: true
                    fontSize: 8
                    textAlignment: 1
                    Layout.alignment: Qt.AlignCenter
                    exclusiveGroup: group1
                    onCheckedChanged: {
                        if (checked) root.state = ""
                    }
                }

                ButtonText {
                    id: buttonText2
                    text: "Stepper"
                    textDefault: "#000000"
                    checkable: true
                    fontSize: 8
                    textAlignment: 1
                    Layout.alignment: Qt.AlignCenter
                    exclusiveGroup: group1
                    onCheckedChanged: {
                        if (checked) root.state = "grid settings"
                    }
                }

                ButtonText {
                    id: buttonText3
                    text: "Keyboard"
                    textDefault: "#000000"
                    checkable: true
                    fontSize: 8
                    textAlignment: 1
                    Layout.alignment: Qt.AlignCenter
                    exclusiveGroup: group1
                    onCheckedChanged: {
                        if (checked) root.state = "keyboard settings"
                    }
                }

                ButtonText {
                    id: buttonText4
                    text: "Miscellaneous"
                    textDefault: "#000000"
                    checkable: true
                    fontSize: 8
                    textAlignment: 1
                    Layout.alignment: Qt.AlignCenter
                    exclusiveGroup: group1
                    onCheckedChanged: {
                        if (checked) root.state = "misc settings"
                    }
                }

                Item {
                    id: spacer
                    Layout.fillHeight: true
                }
            }

        }

        Rectangle {
            id: lineasd
            width: 2
            height: root.height - 40
            color: "#bdc3c7"
        }

        Rectangle {
            id: content
            color: "#ecf0f1"
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            Layout.fillWidth: true

            Item {
                id: cameraContent
                anchors.fill: parent

                Rectangle {
                    id: preview
                    width: 250
                    height: 200
                    color: "#2ecc71"
                    anchors.leftMargin: 40
                    anchors.left: columnLayout1.right
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    border.color: "#bdc3c7"
                    CameraItem {
                        id: previewitem
                        property size offsetSize: optilab.calculateAspectRatio(preview.width, preview.height)
                        anchors.fill: parent
                        Connections {
                            target: camera
                            onFrameReady: previewitem.source = frame
                        }
                        anchors {
                            leftMargin: offsetSize.width; rightMargin: offsetSize.width
                            topMargin: offsetSize.height; bottomMargin: offsetSize.height
                        }
                    }
                }

                ColumnLayout {
                    id: columnLayout1
                    width: 250
                    height: 110
                    spacing: 5
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 20
                    anchors.topMargin: 20

                    TextBlack {
                        id: textBlack1
                        text: "Color"
                        font.pointSize: 10
                    }

                    TextRegular {
                        id: textRegular1
                        text: "Gamma: %1".arg(Math.round(sliderBrightness.value))
                    }

                    Slider {
                        id: sliderBrightness
                        maximumValue: 250
                        minimumValue: 10
                        value: camprop.gamma
                        stepSize: 1.0
                        Layout.alignment: Qt.AlignCenter
                    }

                    TextRegular {
                        id: textRegular2
                        text: "Contrast: %1".arg(Math.round(sliderContrast.value))
                    }

                    Slider {
                        id: sliderContrast
                        value: camprop.contrast
                        maximumValue: 100
                        stepSize: 1
                        Layout.alignment: Qt.AlignCenter
                    }

                    TextRegular {
                        id: textRegular3
                        text: "Saturation: %1".arg(Math.round(sliderSaturation.value))
                    }

                    Slider {
                        id: sliderSaturation
                        value: camprop.saturation
                        maximumValue: 255
                        stepSize: 1
                        Layout.alignment: Qt.AlignCenter
                    }

                    Item { height: 15 }

                    TextBlack {
                        id: textBlack2
                        text: "Exposure"
                        font.pointSize: 10
                    }

                    CheckBox {
                        id: checkboxAutoExposure
                        text: "Automatic Exposure"
                        checked: camprop.autoexposure
                        onCheckedChanged: camprop.autoexposure = checked
                    }

                    TextRegular {
                        id: textRegular4
                        text: "Target: %1".arg(Math.round(sliderTarget.value))
                    }

                    Slider {
                        id: sliderTarget
                        maximumValue: 200
                        minimumValue: 50
                        value: camprop.aeTarget
                        stepSize: 1
                        enabled: checkboxAutoExposure.checked
                        Layout.alignment: Qt.AlignCenter
                    }

                    TextRegular {
                        id: textRegular5
                        text: "Exposure Time: %1".arg(Math.round(sliderTime.value))
                    }

                    Slider {
                        id: sliderTime
                        maximumValue: 4000
                        minimumValue: 1
                        value: camprop.exposureTime
                        stepSize: 1
                        enabled: !checkboxAutoExposure.checked
                        Layout.alignment: Qt.AlignCenter
                    }

                    TextRegular {
                        id: textRegular6
                        text: "Gain: %1".arg(Math.round(sliderGain.value))
                    }

                    Slider {
                        id: sliderGain
                        maximumValue: 80
                        minimumValue: 1
                        value: camprop.aeGain
                        stepSize: 1
                        enabled: !checkboxAutoExposure.checked
                        Layout.alignment: Qt.AlignCenter
                    }

                    Item { height: 15 }

                    TextBlack {
                        id: textBlack3
                        text: "Manual White Balance"
                        font.pointSize: 10
                    }

                    TextRegular {
                        id: textRegular7
                        text: "Red: %1".arg(Math.round(sliderRed.value))
                    }

                    Slider {
                        id: sliderRed
                        maximumValue: 255
                        minimumValue: 10
                        value: camprop.rGain
                        stepSize: 1
                        Layout.alignment: Qt.AlignCenter
                    }

                    TextRegular {
                        id: textRegular8
                        text: "Green: %1".arg(Math.round(sliderGreen.value))
                    }

                    Slider {
                        id: sliderGreen
                        maximumValue: 255
                        minimumValue: 10
                        value: camprop.gGain
                        stepSize: 1
                        Layout.alignment: Qt.AlignCenter
                    }

                    TextRegular {
                        id: textRegular9
                        text: "Blue: %1".arg(Math.round(sliderBlue.value))
                    }

                    Slider {
                        id: sliderBlue
                        maximumValue: 255
                        minimumValue: 10
                        value: camprop.bGain
                        stepSize: 1
                        Layout.alignment: Qt.AlignCenter
                    }
                }

                TextBlack {
                    id: textBlack4
                    text: "Parameter Group"
                    anchors.topMargin: 15
                    anchors.left: preview.left
                    font.pointSize: 10
                    anchors.top: button3.bottom
                }

                ExclusiveGroup { id: group2 }

                GridLayout {
                    id: gridlayout
                    anchors.rightMargin: 20
                    anchors.right: preview.right
                    anchors.leftMargin: 20
                    anchors.topMargin: 10
                    anchors.left: textBlack4.left
                    anchors.top: textBlack4.bottom
                    columnSpacing: 20
                    rowSpacing: 10
                    rows: 5
                    flow: GridLayout.TopToBottom
                    RadioButton {
                        id: radioButton1
                        text: qsTr("A Group")
                        Layout.columnSpan: 2
                        checked: true
                        exclusiveGroup: group2
                        onCheckedChanged: {
                            if (checked) camprop.loadParametersA()
                        }
                    }

                    RadioButton {
                        id: radioButton2
                        text: qsTr("B Group")
                        Layout.columnSpan: 2
                        exclusiveGroup: group2
                        onCheckedChanged: {
                            if (checked) camprop.loadParametersB()
                        }
                    }

                    RadioButton {
                        id: radioButton3
                        text: qsTr("C Group")
                        Layout.columnSpan: 2
                        exclusiveGroup: group2
                        onCheckedChanged: {
                            if (checked) camprop.loadParametersC()
                        }
                    }

                    RadioButton {
                        id: radioButton4
                        text: qsTr("D Group")
                        Layout.columnSpan: 2
                        exclusiveGroup: group2
                        onCheckedChanged: {
                            if (checked) camprop.loadParametersD()
                        }
                    }

                    Button {
                        id: button1
                        text: qsTr("Save")
                        Layout.alignment: Qt.AlignCenter
                        onClicked: {
                            if (radioButton1.checked) camprop.saveParametersA()
                            else if (radioButton2.checked) camprop.saveParametersB()
                            else if (radioButton3.checked) camprop.saveParametersC()
                            else if (radioButton4.checked) camprop.saveParametersD()
                        }
                    }

                    Button {
                        id: button2
                        text: qsTr("Default")
                        Layout.alignment: Qt.AlignCenter
                        onClicked: camprop.loadDefaultParameters()
                    }
                }

                TextItalic {
                    id: textItalic1
                    text: "Camera parameters are not automatically saved by application. To save parameters, please use provided Parameter Group above."
                    font.italic: true
                    anchors.top: gridlayout.bottom
                    anchors.topMargin: 25
                    anchors.right: preview.right
                    anchors.left: preview.left
                    wrapMode: Text.WordWrap
                }

                Button {
                    id: button3
                    x: 393
                    text: qsTr("One Shot WB")
                    anchors.top: preview.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: preview.horizontalCenter
                    onClicked: camprop.oneShotWB()
                }

            }

            Item {
                id: stepperContent
                visible: false
                anchors.fill: parent

                GridLayout {
                    id: gridLayout1
                    rowSpacing: 10
                    columnSpacing: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    columns: 7

                    Item { width: 2 }
                    Item { width: 2 }

                    TextBlack {
                        text: "Soft Limit"
                        font.pointSize: 9
                        Layout.columnSpan: 2
                    }
                    Item { width: 2 }
                    TextBlack {
                        text: "Limit Switches"
                        font.pointSize: 9
                        Layout.columnSpan: 2
                    }

                    Item { width: 2 }
                    TextRegular {
                        text: "Steps/Unit"
                    }
                    TextRegular {
                        text: "Limit Min"
                    }
                    TextRegular {
                        text: "Limit Max"
                    }
                    TextRegular {
                        text: "Enable"
                    }
                    TextRegular {
                        text: "Stop"
                        Layout.columnSpan: 2
                    }

                    TextBlack {
                        text: "X"
                        font.pointSize: 9
                    }
                    SpinBox {
                        id: stepperunitx
                        value: appsettings.readCNCStepsPerUnitX()
                        stepSize: 100
                        maximumValue: 10000
                        minimumValue: 10
                        decimals: 3
                    }
                    SpinBox {
                        id: limitminx
                        value: doublesettings.get(0).value
                        suffix: " mm"
                        maximumValue: 1000
                        decimals: 3
                        onValueChanged: doublesettings.setProperty(0, "value", value)
                    }
                    SpinBox {
                        id: limitmaxx
                        value: doublesettings.get(1).value
                        suffix: " mm"
                        maximumValue: 1000
                        minimumValue: limitminx.value + 1
                        decimals: 3
                        onValueChanged: doublesettings.setProperty(1, "value", value)
                    }
                    CheckBox {
                        id: enablelimitx
                        checked: booleansettings.get(6).value
                        onCheckedChanged: booleansettings.setProperty(6, "value", checked)
                    }
                    CheckBox {
                        id: minstopx
                        text: "Min"
                        checked: booleansettings.get(0).value
                        onCheckedChanged: booleansettings.setProperty(0, "value", checked)
                    }
                    CheckBox {
                        id: maxstopx
                        text: "Max"
                        checked: booleansettings.get(1).value
                        onCheckedChanged: booleansettings.setProperty(1, "value", checked)
                    }

                    TextBlack {
                        text: "Y"
                        font.pointSize: 9
                    }
                    SpinBox {
                        id: stepperunity
                        value: appsettings.readCNCStepsPerUnitY()
                        stepSize: 100
                        minimumValue: 10
                        maximumValue: 10000
                        decimals: 3
                    }
                    SpinBox {
                        id: limitminy
                        value: doublesettings.get(2).value
                        suffix: " mm"
                        maximumValue: 1000
                        decimals: 3
                        onValueChanged: doublesettings.setProperty(2, "value", value)
                    }
                    SpinBox {
                        id: limitmaxy
                        value: doublesettings.get(3).value
                        suffix: " mm"
                        minimumValue: limitminy.value + 1
                        maximumValue: 1000
                        decimals: 3
                        onValueChanged: doublesettings.setProperty(3, "value", value)
                    }
                    CheckBox {
                        id: enablelimity
                        checked: booleansettings.get(7).value
                        onCheckedChanged: booleansettings.setProperty(7, "value", checked)
                    }
                    CheckBox {
                        id: minstopy
                        text: "Min"
                        checked: booleansettings.get(2).value
                        onCheckedChanged: booleansettings.setProperty(2, "value", checked)
                    }
                    CheckBox {
                        id: maxstopy
                        text: "Max"
                        checked: booleansettings.get(3).value
                        onCheckedChanged: booleansettings.setProperty(3, "value", checked)
                    }

                    TextBlack {
                        text: "Z"
                        font.pointSize: 9
                    }
                    SpinBox {
                        id: stepperunitz
                        value: appsettings.readCNCStepsPerUnitZ()
                        stepSize: 100
                        minimumValue: 10
                        maximumValue: 10000
                        decimals: 3
                    }
                    SpinBox {
                        id: limitminz
                        value: doublesettings.get(4).value
                        suffix: " mm"
                        maximumValue: 1000
                        decimals: 3
                        onValueChanged: doublesettings.setProperty(4, "value", value)
                    }
                    SpinBox {
                        id: limitmaxz
                        value: doublesettings.get(5).value
                        suffix: " mm"
                        minimumValue: limitminz.value + 1
                        maximumValue: 1000
                        decimals: 3
                        onValueChanged: doublesettings.setProperty(5, "value", value)
                    }
                    CheckBox {
                        id: enablelimitz
                        checked: booleansettings.get(8).value
                        onCheckedChanged: booleansettings.setProperty(8, "value", checked)
                    }
                    CheckBox {
                        id: minstopz
                        text: "Min"
                        checked: booleansettings.get(4).value
                        onCheckedChanged: booleansettings.setProperty(4, "value", checked)
                    }
                    CheckBox {
                        id: maxstopz
                        text: "Max"
                        checked: booleansettings.get(5).value
                        onCheckedChanged: booleansettings.setProperty(5, "value", checked)
                    }

                }

                GridLayout {
                    rowSpacing: 10
                    columnSpacing: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.top: gridLayout1.bottom
                    anchors.topMargin: 20
                    columns: 3

                    TextBlack {
                        text: "Speed"
                        font.pointSize: 9
                        Layout.columnSpan: 3
                    }
                    TextRegular {
                        text: "Normal"
                    }
                    SpinBox {
                        id: speednormal
                        value: doublesettings.get(7).value
                        maximumValue: 1000
                        minimumValue: 10
                        decimals: 3
                        onValueChanged: doublesettings.setProperty(7, "value", value)
                    }
                    Item { width: 2 }

                    TextRegular {
                        text: "Slow"
                    }
                    SpinBox {
                        id: speedlow
                        value: doublesettings.get(6).value
                        maximumValue: 1000
                        minimumValue: 1
                        decimals: 3
                        onValueChanged: doublesettings.setProperty(6, "value", value)
                    }
                    Item { width: 2 }

                    Item { width: 2; Layout.columnSpan: 3 }

                    TextBlack {
                        text: "Set Zero"
                        font.pointSize: 9
                        Layout.columnSpan: 3
                    }
                    Button {
                        id: xtozero
                        text: "X"
                        tooltip: "Set current X to 0.0"
                        onClicked: setZeroX()
                    }
                    Button {
                        id: ytozero
                        text: "Y"
                        tooltip: "Set current Y to 0.0"
                        onClicked: setZeroY()
                    }
                    Button {
                        id: ztozero
                        text: "Z"
                        tooltip: "Set current Z to 0.0"
                        onClicked: setZeroZ()
                    }

                    TextBlack {
                        text: "Initialize"
                        font.pointSize: 9
                        Layout.columnSpan: 3
                    }
                    Button {
                        id: xinit
                        text: "X"
                        tooltip: "Initialize X axis"
                        onClicked: {
                            initbusy.open()
                            navigator.initializeXAx()
                        }
                    }
                    Button {
                        id: yinit
                        text: "Y"
                        tooltip: "Initialize Y axis"
                        onClicked: {
                            initbusy.open()
                            navigator.initializeYAx()
                        }
                    }
                    Item { width: 2 }
                }
            }

            Item {
                id: keyboardContent
                anchors.fill: parent
                visible: false

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    columns: 3

                    TableView {
                        id: keyboardView
                        model: _model
                        TableViewColumn { role: "command"; title: "Command"; width: 350 }
                        TableViewColumn { role: "shortcut"; title: "Shortcut"; width: 100 }
                        Layout.columnSpan: 3
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                    Button {
                        id: buttonKeyResetAll
                        text: "Reset All"
                        onClicked: {
                            for (var i = 0; i < _model.count; ++i) {
                                var defkey = _model.get(i).keys
                                _model.set(i, { "shortcut": defkey})
                            }
                        }
                    }
                    Item { width: 2 }
                    Item { width: 2 }
                    TextRegular { text: "Shortcut: " }
                    TextField {
                        id: fieldKeyShortcut
                        placeholderText: "Type to set shortcut"
                        echoMode: TextInput.Normal
                        readOnly: true
                        text: (keyboardView.currentRow >= 0) ? _model.get(keyboardView.currentRow).shortcut : ""
                        enabled: (keyboardView.selection.count > 0)
                        Layout.fillWidth: true

                        focus: fieldKeyShortcut.enabled
                        Keys.onPressed: procKeyEvent(event)
                    }
                    Button {
                        id: buttonKeyReset
                        text: "Reset"
                        enabled: (keyboardView.selection.count > 0)
                        onClicked: {
                            var defkey = _model.get(keyboardView.currentRow).keys
                            _model.set(keyboardView.currentRow, { "shortcut": defkey})
                        }
                    }
                }
            }

            Item {
                id: miscContent
                anchors.fill: parent
                visible: false

                ExclusiveGroup { id: group3 }

                ColumnLayout {
                    id: columnLayout2
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    width: 150
                    height: 10
                    spacing: 10

                    TextBlack {
                        id: textBlack6
                        text: "Grid View"
                        font.pointSize: 10
                    }

                    TextRegular {
                        id: textRegular11
                        text: "Column count"
                    }

                    SpinBox {
                        id: gridcolumn
                        value: integersettings.get(0).value
                        maximumValue: 16
                        minimumValue: 1
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignLeft
                        onValueChanged: {
                            requireRestart = true
                            integersettings.setProperty(0, "value", value)
                        }
                    }

                    TextRegular {
                        id: textRegular12
                        text: "Row count"
                    }

                    SpinBox {
                        id: gridrow
                        value: integersettings.get(1).value
                        maximumValue: 16
                        minimumValue: 1
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignLeft
                        onValueChanged: {
                            requireRestart = true
                            integersettings.setProperty(1, "value", value);
                        }
                    }

                    TextRegular {
                        text: "Frame Overlap"
                    }

                    SpinBox {
                        id: gridoverlap
                        value: doublesettings.get(9).value * 100
                        maximumValue: 100
                        minimumValue: 0
                        suffix: " %"
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignLeft
                        onValueChanged: doublesettings.setProperty(9, "value", value / 100.0)
                    }

                    Item { height: 10 }

                    TextBlack {
                        id: textBlack7
                        text: "Map View"
                        font.pointSize: 10
                    }

                    TextRegular {
                        id: textRegular13
                        text: "Scale"
                    }

                    SpinBox {
                        id: mapscale
                        value: 1/doublesettings.get(8).value
                        minimumValue: 1
                        maximumValue: 500
                        prefix: "1 : "
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignLeft
                        onValueChanged: doublesettings.set(8, { "value": 1/value })
                    }

                    TextRegular {
                        text: "Frame Overlap"
                    }

                    SpinBox {
                        id: mapoverlap
                        value: doublesettings.get(10).value * 100
                        maximumValue: 100
                        minimumValue: 0
                        suffix: " %"
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignLeft
                        onValueChanged: doublesettings.setProperty(10, "value", value / 100.0)
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "grid settings"

            PropertyChanges {
                target: stepperContent
                visible: true
            }

            PropertyChanges {
                target: cameraContent
                visible: false
            }
        },
        State {
            name: "misc settings"

            PropertyChanges {
                target: miscContent
                visible: true
            }

            PropertyChanges {
                target: cameraContent
                visible: false
            }
        },
        State {
            name: "keyboard settings"

            PropertyChanges {
                target: keyboardContent
                visible: true
            }

            PropertyChanges {
                target: cameraContent
                visible: false
            }
        }
    ]

    ListModel {
        id: _model

        // Set View
        ListElement {
            name: "View.Single"
            command: "(Global) Single View"
            shortcut: "Ctrl+1"
            keys: "Ctrl+1"
        }
        ListElement {
            name: "View.Grid"
            command: "(Global) Grid View"
            shortcut: "Ctrl+2"
            keys: "Ctrl+2"
        }
        ListElement {
            name: "View.Map"
            command: "(Global) Map View"
            shortcut: "Ctrl+3"
            keys: "Ctrl+3"
        }
        ListElement {
            name: "View.Calibration"
            command: "(Global) Calibration View"
            shortcut: "Ctrl+4"
            keys: "Ctrl+4"
        }
        ListElement {
            name: "View.Settings"
            command: "(Global) Open Settings Page"
            shortcut: "F2"
            keys: "F2"
        }

        // Camera
        ListElement {
            name: "WhiteBalance"
            command: "(Global) One shot white balance"
            shortcut: "Space"
            keys: "Space"
        }
        ListElement {
            name: "AutoExposure"
            command: "(Global) Toggle automatic exposure"
            shortcut: "E"
            keys: "E"
        }
        ListElement {
            name: "ParamsDefault"
            command: "(Global) Load default parameter group"
            shortcut: "F4"
            keys: "F4"
        }
        ListElement {
            name: "ParamsA"
            command: "(Global) Load parameter group A"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "ParamsB"
            command: "(Global) Load parameter group B"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "ParamsC"
            command: "(Global) Load parameter group C"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "ParamsD"
            command: "(Global) Load parameter group D"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "GammaUp"
            command: "(Global) Increase brightness"
            shortcut: "."
            keys: "."
        }
        ListElement {
            name: "GammaDown"
            command: "(Global) Decrease brightness"
            shortcut: ","
            keys: ","
        }
        ListElement {
            name: "ContrastUp"
            command: "(Global) Increase contrast"
            shortcut: "'"
            keys: "'"
        }
        ListElement {
            name: "ContrastDown"
            command: "(Global) Decrease contrast"
            shortcut: ";"
            keys: ";"
        }
        ListElement {
            name: "SaturationUp"
            command: "(Global) Increase saturation"
            shortcut: "Shift+>"
            keys: "Shift+>"
        }
        ListElement {
            name: "SaturationDown"
            command: "(Global) Decrease saturation"
            shortcut: "Shift+<"
            keys: "Shift+<"
        }
        ListElement {
            name: "TargetUp"
            command: "(Global) Increase auto exposure target area"
            shortcut: "]"
            keys: "]"
        }
        ListElement {
            name: "TargetDown"
            command: "(Global) Decrease auto exposure target area"
            shortcut: "["
            keys: "["
        }
        ListElement {
            name: "AetimeUp"
            command: "(Global) Increase exposure time"
            shortcut: "Shift+}"
            keys: "Shift+}"
        }
        ListElement {
            name: "AetimeDown"
            command: "(Global) Decrease exposure time"
            shortcut: "Shift+{"
            keys: "Shift+{"
        }
        ListElement {
            name: "GainUp"
            command: "(Global) Increase exposure gain"
            shortcut: 'Shift+"'
            keys: 'Shift+"'
        }
        ListElement {
            name: "GainDown"
            command: "(Global) Decrease exposure gain"
            shortcut: 'Shift+:'
            keys: 'Shift+:'
        }
        ListElement {
            name: "RedUp"
            command: "(Global) Increase red channel gain"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "RedDown"
            command: "(Global) Decrease red channel gain"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "GreenUp"
            command: "(Global) Increase green channel gain"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "GreenDown"
            command: "(Global) Decrease green channel gain"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "BlueUp"
            command: "(Global) Increase blue channel gain"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "BlueDown"
            command: "(Global) Decrease blue channel gain"
            shortcut: ""
            keys: ""
        }

        // Jog
        ListElement {
            name: "JogUp"
            command: "(Global) Move up"
            shortcut: "Up"
            keys: "Up"
        }
        ListElement {
            name: "JogRight"
            command: "(Global) Move right"
            shortcut: "Right"
            keys: "Right"
        }
        ListElement {
            name: "JogDown"
            command: "(Global) Move down"
            shortcut: "Down"
            keys: "Down"
        }
        ListElement {
            name: "JogLeft"
            command: "(Global) Move left"
            shortcut: "Left"
            keys: "Left"
        }
        ListElement {
            name: "JogZUp"
            command: "(Global) Move up along z axis"
            shortcut: "PgUp"
            keys: "PgUp"
        }
        ListElement {
            name: "JogZDown"
            command: "(Global) Move down along z axis"
            shortcut: "PgDown"
            keys: "PgDown"
        }

        // Frame Jog
        ListElement {
            name: "FrameUp"
            command: "(Global) Move up by one frame"
            shortcut: "W"
            keys: "W"
        }
        ListElement {
            name: "FrameRight"
            command: "(Global) Move right by one frame"
            shortcut: "D"
            keys: "D"
        }
        ListElement {
            name: "FrameDown"
            command: "(Global) Move down by one frame"
            shortcut: "S"
            keys: "S"
        }
        ListElement {
            name: "FrameLeft"
            command: "(Global) Move left by one frame"
            shortcut: "A"
            keys: "A"
        }

        // Micron Jog
        ListElement {
            name: "MicronUp"
            command: "(Global) Move up by one micron"
            shortcut: "Ctrl+W"
            keys: "Ctrl+W"
        }
        ListElement {
            name: "MicronRight"
            command: "(Global) Move right by one micron"
            shortcut: "Ctrl+D"
            keys: "Ctrl+D"
        }
        ListElement {
            name: "MicronDown"
            command: "(Global) Move down by one micron"
            shortcut: "Ctrl+S"
            keys: "Ctrl+S"
        }
        ListElement {
            name: "MicronLeft"
            command: "(Global) Move left by one micron"
            shortcut: "Ctrl+A"
            keys: "Ctrl+A"
        }
        ListElement {
            name: "MicronZUp"
            command: "(Global) Move up along z axis by one micron"
            shortcut: "Alt+PgUp"
            keys: "Alt+PgUp"
        }
        ListElement {
            name: "MicronZDown"
            command: "(Global) Move down along z axis by one micron"
            shortcut: "Alt+PgDown"
            keys: "Alt+PgDown"
        }

        // Slow Jog
        ListElement {
            name: "JogSlowUp"
            command: "(Global) Move up slowly"
            shortcut: "Ctrl+Up"
            keys: "Ctrl+Up"
        }
        ListElement {
            name: "JogSlowRight"
            command: "(Global) Move right slowly"
            shortcut: "Ctrl+Right"
            keys: "Ctrl+Right"
        }
        ListElement {
            name: "JogSlowDown"
            command: "(Global) Move down slowly"
            shortcut: "Ctrl+Down"
            keys: "Ctrl+Down"
        }
        ListElement {
            name: "JogSlowLeft"
            command: "(Global) Move left slowly"
            shortcut: "Ctrl+Left"
            keys: "Ctrl+Left"
        }
        ListElement {
            name: "JogSlowZUp"
            command: "(Global) Move up along z axis slowly"
            shortcut: "Ctrl+PgUp"
            keys: "Ctrl+PgUp"
        }
        ListElement {
            name: "JogSlowZDown"
            command: "(Global) Move down along z axis slowly"
            shortcut: "Ctrl+PgDown"
            keys: "Ctrl+PgDown"
        }

        // Single View
        ListElement {
            name: "Single.SingleCapture"
            command: "(SingleView) Single Capture"
            shortcut: "F5"
            keys: "F5"
        }
        ListElement {
            name: "Single.CountCapture"
            command: "(SingleView) Start serial capture mode count"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.CountIntervalUp"
            command: "(SingleView) Increase interval time for capture mode count"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.CountIntervalDown"
            command: "(SingleView) Decrease interval time for capture mode count"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.CountUp"
            command: "(SingleView) Increase frame count for capture mode count"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.CountDown"
            command: "(SingleView) Decrease frame count for capture mode count"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.DurationCapture"
            command: "(SingleView) Start serial capture mode duration"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.DurationIntervalUp"
            command: "(SingleView) Increase interval time for capture mode duration"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.DurationIntervalDown"
            command: "(SingleView) Decrease interval time for capture mode duration"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.DurationUp"
            command: "(SingleView) Increase duration time for capture mode count"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.DurationDown"
            command: "(SingleView) Decrease duration time for capture mode count"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.StartRecording"
            command: "(SingleView) Start Recording"
            shortcut: "F6"
            keys: "F6"
        }
        ListElement {
            name: "Single.PauseRecording"
            command: "(SingleView) Pause Recording"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Single.StopRecording"
            command: "(SingleView) Stop Recording"
            shortcut: "F7"
            keys: "F7"
        }

        // Grid View
        ListElement {
            name: "Grid.SelectUp"
            command: "(GridView) Select up cell"
            shortcut: "Up"
            keys: "Up"
        }
        ListElement {
            name: "Grid.SelectRight"
            command: "(GridView) Select right cell"
            shortcut: "Right"
            keys: "Right"
        }
        ListElement {
            name: "Grid.SelectDown"
            command: "(GridView) Select down cell"
            shortcut: "Down"
            keys: "Down"
        }
        ListElement {
            name: "Grid.SelectLeft"
            command: "(GridView) Select left cell"
            shortcut: "Left"
            keys: "Left"
        }
        ListElement {
            name: "Grid.ShiftUp"
            command: "(GridView) Shift Up"
            shortcut: "W"
            keys: "W"
        }
        ListElement {
            name: "Grid.ShiftRight"
            command: "(GridView) Shift Right"
            shortcut: "D"
            keys: "D"
        }
        ListElement {
            name: "Grid.ShiftDown"
            command: "(GridView) Shift Down"
            shortcut: "S"
            keys: "S"
        }
        ListElement {
            name: "Grid.ShiftLeft"
            command: "(GridView) Shift Left"
            shortcut: "A"
            keys: "A"
        }
        ListElement {
            name: "Grid.MoveToSelected"
            command: "(GridView) Move to selected"
            shortcut: "Return"
            keys: "Return"
        }
        ListElement {
            name: "Grid.FillSelection"
            command: "(GridView) Fill selected cells"
            shortcut: "F9"
            keys: "F9"
        }
        ListElement {
            name: "Grid.AutoFill"
            command: "(GridView) Automatically fill cells"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Grid.SaveSelected"
            command: "(GridView) Save selected cells"
            shortcut: "Ctrl+S"
            keys: "Ctrl+S"
        }
        ListElement {
            name: "Grid.SaveAll"
            command: "(GridView) Save all cells with image"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Grid.ClearSelected"
            command: "(GridView) Clear selected cells"
            shortcut: "Del"
            keys: "Del"
        }
        ListElement {
            name: "Grid.InvertClear"
            command: "(GridView) Clear all except selected cells"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Grid.ClearBuffers"
            command: "(GridView) Clear all cells"
            shortcut: ""
            keys: ""
        }
        ListElement {
            name: "Grid.Enlarge"
            command: "(GridView) Enlarge cells"
            shortcut: "PgUp"
            keys: "PgUp"
        }
        ListElement {
            name: "Grid.Shrink"
            command: "(GridView) Shrink cells"
            shortcut: "PgDown"
            keys: "PgDown"
        }

        // Map View
        ListElement {
            name: "Map.StartCapture"
            command: "(MapView) Start capture"
            shortcut: "F10"
            keys: "F10"
        }
        ListElement {
            name: "Map.MarkPoint1"
            command: "(MapView) Mark current position as point 1"
            shortcut: "1"
            keys: "1"
        }
        ListElement {
            name: "Map.MarkPoint2"
            command: "(MapView) Mark current position as point 2"
            shortcut: "2"
            keys: "2"
        }
        ListElement {
            name: "Map.MarkPoint3"
            command: "(MapView) Mark current position as point 3"
            shortcut: "3"
            keys: "3"
        }
        ListElement {
            name: "Map.MarkPoint4"
            command: "(MapView) Mark current position as point 4"
            shortcut: "4"
            keys: "4"
        }
    }

    function getIndex(name) {
        for (var i = 0; i < _model.count; ++i) {
            if (name === _model.get(i).name)
                return i
        }
        return -1
    }

    function procKeyEvent(event) {
        var rejectedKeys = [Qt.Key_unknown, Qt.Key_Control, Qt.Key_Alt, Qt.Key_Shift, Qt.Key_Escape,
                            Qt.Key_CapsLock, Qt.Key_NumLock, Qt.Key_AltGr, Qt.Key_ScrollLock, Qt.Key_Print,
                            Qt.Key_Pause, Qt.Key_Backspace, Qt.Key_Return, Qt.Key_Enter, Qt.Key_SysReq, Qt.Key_Clear,
                            Qt.Key_Meta, Qt.Key_Menu, Qt.Key_Tab]
        var invalidModifiers = [Qt.MetaModifier, Qt.KeypadModifier]
        for (var k in rejectedKeys) {
            if (event.key === rejectedKeys[k]) return
        }
        for (var m in invalidModifiers) {
            if (event.modifiers === invalidModifiers[m]) return
        }
        var key = appsettings.keyCodeToString(event.key + event.modifiers)
        for (var i = 0; i < _model.count; ++i) {
            if (_model.get(i).shortcut === key)
                _model.set(i, { "shortcut": "" })
        }
        _model.setProperty(keyboardView.currentRow, "shortcut", key)
        event.key.accepted = true
    }

    ListModel {
        id: doublesettings
        ListElement {
            name: "LimitXMin"
            value: 0.0
            defval: 0.0
        }
        ListElement {
            name: "LimitXMax"
            value: 150.0
            defval: 150.0
        }
        ListElement {
            name: "LimitYMin"
            value: 0.0
            defval: 0.0
        }
        ListElement {
            name: "LimitYMax"
            value: 100.0
            defval: 100.0
        }
        ListElement {
            name: "LimitZMin"
            value: 0.0
            defval: 0.0
        }
        ListElement {
            name: "LimitZMax"
            value: 100.0
            defval: 100.0
        }
        ListElement {
            name: "SpeedLo"
            value: 10.0
            defval: 10.0
        }
        ListElement {
            name: "SpeedHi"
            value: 100.0
            defval: 100.0
        }
        ListElement {
            name: "MapScale"
            value: 0.01
            defval: 0.01
        }
        ListElement {
            name: "GridOverlap"
            value: 0.25
            defval: 0.25
        }
        ListElement {
            name: "MapOverlap"
            value: 0.25
            defval: 0.25
        }
    }

    ListModel {
        id: booleansettings
        ListElement {
            name: "StopOnMinX"
            value: true
            defval: true
        }
        ListElement {
            name: "StopOnMaxX"
            value: true
            defval: true
        }
        ListElement {
            name: "StopOnMinY"
            value: true
            defval: true
        }
        ListElement {
            name: "StopOnMaxY"
            value: true
            defval: true
        }
        ListElement {
            name: "StopOnMinZ"
            value: true
            defval: true
        }
        ListElement {
            name: "StopOnMaxZ"
            value: true
            defval: true
        }
        ListElement {
            name: "EnableLimitX"
            value: true
            defval: true
        }
        ListElement {
            name: "EnableLimitY"
            value: true
            defval: true
        }
        ListElement {
            name: "EnableLimitZ"
            value: true
            defval: true
        }
    }

    ListModel {
        id: integersettings
        ListElement {
            name: "GridCol"
            value: 13
            defval: 13
        }
        ListElement {
            name: "GridRow"
            value: 13
            defval: 13
        }
    }

    Component.onCompleted: {
        var lastParams = appsettings.readInt("CameraLastParams", 0)
        if (lastParams === 0) radioButton1.checked = true
        else if (lastParams === 1) radioButton2.checked = true
        else if (lastParams === 2) radioButton3.checked = true
        else radioButton4.checked = true
    }

    Binding { target: camprop; property: "rGain"; value: sliderRed.value   }
    Binding { target: camprop; property: "gGain"; value: sliderGreen.value }
    Binding { target: camprop; property: "bGain"; value: sliderBlue.value }
    Binding { target: camprop; property: "gamma"; value: sliderBrightness.value }
    Binding { target: camprop; property: "contrast"; value: sliderContrast.value }
    Binding { target: camprop; property: "saturation"; value: sliderSaturation.value }
    Binding { target: camprop; property: "aeTarget"; value: sliderTarget.value }
    Binding { target: camprop; property: "exposureTime"; value: sliderTime.value }
    Binding { target: camprop; property: "aeGain"; value: sliderGain.value }
}

