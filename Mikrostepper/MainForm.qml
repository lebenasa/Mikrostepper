import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2

Item {
    id: root
    property alias keysModel: settingspage.keysModel

    width: 1280
    height: 720

    MouseArea {
        id: rootma
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: {
            profilemenu.visible = false
        }
    }

    Rectangle {
        id: profilemenu
//        flags: Qt.Popup | Qt.WindowStaysOnTopHint
        z: 1000
        x: buttonText3.x + buttonText3.width - width
        y: ribboncontent.y
        visible: false
        width: 100
        height: profilelist.count * 25 + 3 + 25
        ColumnLayout {
            anchors.fill: parent
            ListView {
                id: profilelist
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                model: editor.profileModel
                delegate: ButtonText {
                    text: name
                    fontSize: 9
                    limitText: true
                    limitSize: true
                    textAlignment: Text.AlignRight
                    onClicked: {
                        appsettings.profileId = index
                        profilemenu.visible = false
                    }
                }
                Connections {
                    target: appsettings
                    onProfileUpdated: {
                        profilelist.model = editor.profileModel
                    }
                }
            }
            ButtonText {
                id: buttonCalibrate
                text: "Calibrate"
                fontSize: 9
                checkable: true
                checked: false
                exclusiveGroup: group1
                textUnchecked: textDefault
                onCheckedChanged: {
                    profilemenu.visible = false
                    if (checked) {
                        root.state = ""
                        singlecontent.calibrationSwitch = true
                        viewerRibbon.visible = false
                        calibrateRibbon.visible = true
                    }
                }
            }
        }
    }

    Dialog {
        id: dgProfile
        title: "Calibration Profile Editor"
        width: 480
        height: 320
        contentItem: CustomProfile {
            id: editor
            pixelWidth: singlecontent.pixelWidth; pixelHeight: singlecontent.pixelHeight
            realWidth: singlecontent.realWidth; realHeight: singlecontent.realHeight
            screenWidth: singlecontent.screenWidth; screenHeight: singlecontent.screenHeight
            onDone: dgProfile.visible = false
        }
    }

    Dialog {
        id: dgSettings
        width: 800
        height: 600
        standardButtons: StandardButton.RestoreDefaults | StandardButton.Ok | StandardButton.Cancel
        SettingsPage {
            id: settingspage
        }
        onAccepted: {
            settingspage.updateSettings()
            if (settingspage.requireRestart) requestreset.open()
        }
        onReset: confirmreset.open()
    }

    MessageDialog {
        id: confirmreset
        title: "Confirm Settings Reset"
        text: "Reset all settings. Are you sure?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            settingspage.restoreSettings()
            requestreset.open()
        }
    }

    MessageDialog {
        id: requestreset
        title: "Restart to Apply Changes"
        text: "Some settings will take effect next time application started."
        standardButtons: StandardButton.Ok
    }

    Item {
        id: ribbon
        height: 150
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        Behavior on height { PropertyAnimation { duration: 150 } }
        z: 80

        Item {
            id: ribbonmenu
            height: parent.height - 120
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left

            ExclusiveGroup { id: group1 }

            ButtonText {
                id: buttonSimple1
                text: "single view"
                tooltip: "Open Single View. Basic capture and recording features."
                fontSize: 11
                checkable: true
                checked: true
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                exclusiveGroup: group1
                onCheckedChanged: {
                    if (checked) {
                        serialcapture.flushCommand()
                        root.state = ""
                        singlecontent.calibrationSwitch = false
                        viewerRibbon.visible = true
                        calibrateRibbon.visible = false
                    }
                }
            }

            ButtonText {
                id: buttonText1
                text: "grid view"
                tooltip: "Open Grid View. Suitable for capturing large area quickly and easily."
                fontSize: 11
                checkable: true
                checked: false
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: buttonSimple1.right
                exclusiveGroup: group1
                onCheckedChanged: {
                    if (checked) {
                        serialcapture.updateCenter()
                        root.state = "grid_view"
                    }
                }
            }

            ButtonText {
                id: buttonText2
                text: "map view"
                tooltip: "Open Map View. Suitable for very large capture area."
                checkable: true
                fontSize: 11
                anchors.leftMargin: 5
                anchors.left: buttonText1.right
                anchors.verticalCenter: parent.verticalCenter
                exclusiveGroup: group1
                onCheckedChanged: {
                    if (checked) {
                        serialcapture.flushCommand()
                        root.state = "map_view"
                    }
                }
            }

            ButtonText {
                id: buttonText3
                property string profileName: appsettings.readProfileName(appsettings.profileId)
                text: "Profile: %1".arg(profileName)
                fontSize: 9
                anchors.rightMargin: 5
                textAlignment: Text.AlignRight
                anchors.right: rectangle1.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    profilemenu.visible = !profilemenu.visible
                }

                Connections {
                    target: appsettings
                    onProfileIdChanged: {
                        buttonText3.profileName = appsettings.readProfileName(appsettings.profileId)
                    }
                }
            }

            Rectangle {
                id: rectangle1
                width: 2
                height: 20
                color: "#bdc3c7"
                anchors.right: buttonText4.left
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
            }

            ButtonText {
                id: buttonText4
                width: 60
                text: "Settings"
                fontSize: 9
                anchors.rightMargin: 0
                anchors.right: parent.right
                textAlignment: Text.AlignLeft
                anchors.verticalCenter: parent.verticalCenter
                onClicked: actionViewSettings.trigger()
            }
        }

        Item {
            id: ribboncontent
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.top: ribbonmenu.bottom

            CalibrateRibbon {
                id: calibrateRibbon
                anchors.fill: parent
                visible: false
                onRequestSave: dgProfile.visible = true
            }

            ViewerRibbon {
                id: viewerRibbon
                anchors.fill: parent
            }

            GridRibbon {
                id: gridRibbon
                visible: false
                anchors.fill: parent
            }

            MapRibbon {
                id: mapRibbon
                visible: false
                anchors.fill: parent
                onMark1Changed: actionMapMarkPoint1.trigger()
                onMark2Changed: actionMapMarkPoint2.trigger()
                onMark3Changed: actionMapMarkPoint3.trigger()
                onMark4Changed: actionMapMarkPoint4.trigger()
            }
        }
    }

    Item {
        id: content
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: status.top
        anchors.top: ribbon.bottom

        SerialCapture {
            id: gridcontent
            visible: false
            scale: 1.2
            anchors.fill: parent
            z: -10
        }

        OptilabViewer {
            id: singlecontent
            anchors.fill: parent
            focus: visible
            Keys.onPressed: procKeyPress(event)
            Keys.onReleased: procKeyRelease(event)
        }

        MapView {
            id: mapcontent
            scale: 1.3
            visible: false
            anchors.fill: parent
            z: -20
            focus: visible
            Keys.onPressed: procKeyPress(event)
            Keys.onReleased: procKeyRelease(event)
        }
    }

    Rectangle {
        id: status
        height: 25
        color: "#ffffff"
        border.color: "#95a5a6"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        Behavior on height { PropertyAnimation { duration: 150 } }
        RowLayout {
            anchors.fill: parent
            TextRegular {
                id: coordstatus
                text: navigator.coordinateString
                Layout.fillWidth: true
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 9
            }
            Rectangle {
                width: 2
                height: 20
                color: "#bdc3c7"
            }
            TextRegular {
                id: aestatus
                property string aestat: (camprop.autoexposure) ? "ON" : "OFF"
                text: "AE: %1".arg(aestat)
            }
            Rectangle {
                width: 2
                height: 20
                color: "#bdc3c7"
            }
            Item {
                Layout.minimumWidth: 100
            }
            TextRegular {
                id: recordtime
                visible: (optilab.recordingStatus != 0)
                Connections {
                    target: optilab
                    onRecordingTime: recordtime.text = time
                }
                font.pointSize: 9
            }
        }
    }

    states: [
        State {
            name: "no_ribbon"

            PropertyChanges {
                target: ribbon
                height: 0
            }

            PropertyChanges {
                target: status
                height: 0
            }
        },
        State {
            name: "grid_view"

            PropertyChanges {
                target: gridRibbon
                visible: true
            }

            PropertyChanges {
                target: viewerRibbon
                visible: false
            }

            PropertyChanges {
                target: gridcontent
                scale: 1.0
                visible: true
            }

            PropertyChanges {
                target: singlecontent
                anchors.rightMargin: 0
                anchors.bottomMargin: -243
                anchors.leftMargin: 0
                anchors.topMargin: 243
                scale: 0.1
                visible: false
            }
        },
        State {
            name: "map_view"

            PropertyChanges {
                target: viewerRibbon
                visible: false
            }

            PropertyChanges {
                target: mapRibbon
                visible: true
            }

            PropertyChanges {
                target: mapcontent
                scale: 1
                visible: true
            }

            PropertyChanges {
                target: singlecontent
                scale: 0.1
                anchors.topMargin: 243
                anchors.bottomMargin: -243
                visible: false
            }

            PropertyChanges {
                target: gridcontent
                anchors.rightMargin: 0
                anchors.bottomMargin: -243
                anchors.leftMargin: 0
                anchors.topMargin: 243
                scale: 0.1
                visible: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "grid_view"
            to: ""
            reversible: true
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAction { target: singlecontent; properties: "visible"; }
                    PropertyAnimation { target: gridcontent; properties: "scale"; duration: 250 }
                    PropertyAnimation { target: singlecontent; properties: "anchors.bottomMargin, anchors.topMargin"; duration: 250 }
                    PropertyAnimation { target: singlecontent; properties: "scale"; duration: 250 }
                }
                PropertyAction { target: gridcontent; properties: "visible"; }
            }
        },
        Transition {
            from: "grid_view"
            to: "map_view"
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAction { target: mapcontent; properties: "visible"; }
                    PropertyAnimation { target: mapcontent; properties: "scale"; duration: 250 }
                    PropertyAnimation { target: gridcontent; properties: "anchors.bottomMargin, anchors.topMargin"; duration: 250 }
                    PropertyAnimation { target: gridcontent; properties: "scale"; duration: 250 }
                }
                PropertyAction { target: gridcontent; properties: "visible"; }
            }
            reversible: true
        },
        Transition {
            from: ""
            to: "map_view"
            reversible: true
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAction { target: mapcontent; properties: "visible"; }
                    PropertyAnimation { target: mapcontent; properties: "scale"; duration: 250 }
                    PropertyAnimation { target: singlecontent; properties: "anchors.bottomMargin, anchors.topMargin"; duration: 250 }
                    PropertyAnimation { target: singlecontent; properties: "scale"; duration: 250 }
                }
                ParallelAnimation {
                    PropertyAction { target: singlecontent; properties: "visible"; }
                    PropertyAction { target: viewerRibbon; properties: "visible"; }
                }
            }
        }
    ]

    function updateSettings() {
        navigator.initSettings()
    }

    Connections {
        target: appsettings
        onProfileIdChanged: updateSettings()
        onProfileUpdated: updateSettings()
        onSettingsChanged: updateSettings()
    }

    function getIndex(name) {
        for (var i = 0; i < keysModel.count; ++i) {
            if (name === keysModel.get(i).name)
                return i
        }
        return -1
    }

    property string jogKeyUp: keysModel.get(getIndex("JogUp")).shortcut
    property string jogKeyRight: keysModel.get(getIndex("JogRight")).shortcut
    property string jogKeyDown: keysModel.get(getIndex("JogDown")).shortcut
    property string jogKeyLeft: keysModel.get(getIndex("JogLeft")).shortcut

    property string jogKeyZUp: keysModel.get(getIndex("JogZUp")).shortcut
    property string jogKeyZDown: keysModel.get(getIndex("JogZDown")).shortcut

    property string jogSlowKeyUp: keysModel.get(getIndex("JogSlowUp")).shortcut
    property string jogSlowKeyRight: keysModel.get(getIndex("JogSlowRight")).shortcut
    property string jogSlowKeyDown: keysModel.get(getIndex("JogSlowDown")).shortcut
    property string jogSlowKeyLeft: keysModel.get(getIndex("JogSlowLeft")).shortcut

    property string jogSlowKeyZUp: keysModel.get(getIndex("JogSlowZUp")).shortcut
    property string jogSlowKeyZDown: keysModel.get(getIndex("JogSlowZDown")).shortcut

    property string frameUp: keysModel.get(getIndex("FrameUp")).shortcut
    property string frameRight: keysModel.get(getIndex("FrameRight")).shortcut
    property string frameDown: keysModel.get(getIndex("FrameDown")).shortcut
    property string frameLeft: keysModel.get(getIndex("FrameLeft")).shortcut

    property string micronUp: keysModel.get(getIndex("MicronUp")).shortcut
    property string micronRight: keysModel.get(getIndex("MicronRight")).shortcut
    property string micronDown: keysModel.get(getIndex("MicronDown")).shortcut
    property string micronLeft: keysModel.get(getIndex("MicronLeft")).shortcut
    property string micronZUp: keysModel.get(getIndex("MicronZUp")).shortcut
    property string micronZDown: keysModel.get(getIndex("MicronZDown")).shortcut

    property string currentKey: ""
    function procKeyPress(event) {
        if (event.isAutoRepeat || currentKey != "") return
        var val = appsettings.keyCodeToString(event.modifiers + event.key)
        var key = appsettings.keyCodeToString(event.key)
        if (val === jogKeyUp) {
            currentKey = key
            navigator.jogXY(0, -1)
        }
        else if (val === jogKeyRight) {
            currentKey = key
            navigator.jogXY(1, 0)
        }
        else if (val === jogKeyDown) {
            currentKey = key
            navigator.jogXY(0, 1)
        }
        else if (val === jogKeyLeft) {
            currentKey = key
            navigator.jogXY(-1, 0)
        }
        else if (val === jogKeyZUp) {
            currentKey = key
            navigator.jogZ(1)
        }
        else if (val === jogKeyZDown) {
            currentKey = key
            navigator.jogZ(-1)
        }

        else if (val === jogSlowKeyUp) {
            currentKey = key
            navigator.jogSlowXY(0, -1)
        }
        else if (val === jogSlowKeyRight) {
            currentKey = key
            navigator.jogSlowXY(1, 0)
        }
        else if (val === jogSlowKeyDown) {
            currentKey = key
            navigator.jogSlowXY(0, 1)
        }
        else if (val === jogSlowKeyLeft) {
            currentKey = key
            navigator.jogSlowXY(-1, 0)
        }
        else if (val === jogSlowKeyZUp) {
            currentKey = key
            navigator.jogSlowZ(1)
        }
        else if (val === jogSlowKeyZDown) {
            currentKey = key
            navigator.jogSlowZ(-1)
        }

        else if (val === frameUp) {
            navigator.frameXY(0, -1)
        }
        else if (val === frameRight) {
            navigator.frameXY(1, 0)
        }
        else if (val === frameDown) {
            navigator.frameXY(0, 1)
        }
        else if (val === frameLeft) {
            navigator.frameXY(-1, 0)
        }

        else if (val === micronUp) {
            navigator.micronXY(0, -1)
        }
        else if (val === micronRight) {
            navigator.micronXY(1, 0)
        }
        else if (val === micronDown) {
            navigator.micronXY(0, 1)
        }
        else if (val === micronLeft) {
            navigator.micronXY(-1, 0)
        }
        else if (val === micronZUp) {
            navigator.micronZ(1)
        }
        else if (val === micronZDown) {
            navigator.micronZ(-1)
        }
    }

    function procKeyRelease(event) {
        if (event.isAutoRepeat || currentKey == "") return
        var val = appsettings.keyCodeToString(event.key)
        if (val === currentKey) {
            currentKey = ""
            navigator.stop()
        }
    }

    Action {
        id: actionWhiteBalance
        shortcut: keysModel.get(getIndex("WhiteBalance")).shortcut
        onTriggered: camprop.oneShotWB()
    }
    Action {
        id: actionAutoExposure
        shortcut: keysModel.get(getIndex("AutoExposure")).shortcut
        onTriggered: camprop.autoexposure = !camprop.autoexposure
    }
    Action {
        id: actionParamsDefault
        shortcut: keysModel.get(getIndex("ParamsDefault")).shortcut
        onTriggered: camprop.loadDefaultParameters()
    }
    Action {
        id: actionParamsA
        shortcut: keysModel.get(getIndex("ParamsA")).shortcut
        onTriggered: camprop.loadParametersA()
    }
    Action {
        id: actionParamsB
        shortcut: keysModel.get(getIndex("ParamsB")).shortcut
        onTriggered: camprop.loadParametersB()
    }
    Action {
        id: actionParamsC
        shortcut: keysModel.get(getIndex("ParamsC")).shortcut
        onTriggered: camprop.loadParametersC()
    }
    Action {
        id: actionParamsD
        shortcut: keysModel.get(getIndex("ParamsD")).shortcut
        onTriggered: camprop.loadParametersD()
    }
    Action {
        id: actionGammaUp
        shortcut: keysModel.get(getIndex("GammaUp")).shortcut
        onTriggered: camprop.gamma += 1
    }
    Action {
        id: actionGammaDown
        shortcut: keysModel.get(getIndex("GammaDown")).shortcut
        onTriggered: camprop.gamma -= 1
    }
    Action {
        id: actionContrastUp
        shortcut: keysModel.get(getIndex("ContrastUp")).shortcut
        onTriggered: camprop.contrast += 1
    }
    Action {
        id: actionContrastDown
        shortcut: keysModel.get(getIndex("ContrastDown")).shortcut
        onTriggered: camprop.contrast -= 1
    }
    Action {
        id: actionSaturationUp
        shortcut: keysModel.get(getIndex("SaturationUp")).shortcut
        onTriggered: camprop.saturation += 1
    }
    Action {
        id: actionSaturationDown
        shortcut: keysModel.get(getIndex("SaturationDown")).shortcut
        onTriggered: camprop.saturation -= 1
    }
    Action {
        id: actionTargetUp
        shortcut: keysModel.get(getIndex("TargetUp")).shortcut
        onTriggered: {
            if (camprop.autoexposure) camprop.aeTarget += 1
        }
    }
    Action {
        id: actionTargetDown
        shortcut: keysModel.get(getIndex("TargetDown")).shortcut
        onTriggered: {
            if (camprop.autoexposure) camprop.aeTarget -= 1
        }
    }
    Action {
        id: actionAetimeUp
        shortcut: keysModel.get(getIndex("AetimeUp")).shortcut
        onTriggered: {
            if (!camprop.autoexposure) camprop.exposureTime += 10
        }
    }
    Action {
        id: actionAetimeDown
        shortcut: keysModel.get(getIndex("AetimeDown")).shortcut
        onTriggered: {
            if (!camprop.autoexposure) camprop.exposureTime -= 10
        }
    }
    Action {
        id: actionGainUp
        shortcut: keysModel.get(getIndex("GainUp")).shortcut
        onTriggered: {
            if (!camprop.autoexposure) camprop.aeGain += 1
        }
    }
    Action {
        id: actionGainDown
        shortcut: keysModel.get(getIndex("GainDown")).shortcut
        onTriggered: {
            if (!camprop.autoexposure) camprop.aeGain -= 1
        }
    }
    Action {
        id: actionRedUp
        shortcut: keysModel.get(getIndex("RedUp")).shortcut
        onTriggered: camprop.rGain += 1
    }
    Action {
        id: actionRedDown
        shortcut: keysModel.get(getIndex("RedDown")).shortcut
        onTriggered: camprop.rGain -= 1
    }
    Action {
        id: actionGreenUp
        shortcut: keysModel.get(getIndex("GreenUp")).shortcut
        onTriggered: camprop.gGain += 1
    }
    Action {
        id: actionGreenDown
        shortcut: keysModel.get(getIndex("GreenDown")).shortcut
        onTriggered: camprop.gGain -= 1
    }
    Action {
        id: actionBlueUp
        shortcut: keysModel.get(getIndex("BlueUp")).shortcut
        onTriggered: camprop.bGain += 1
    }
    Action {
        id: actionBlueDown
        shortcut: keysModel.get(getIndex("BlueDown")).shortcut
        onTriggered: camprop.bGain -= 1
    }

    Action {
        id: actionSingleView
        onTriggered: buttonSimple1.checked = true
        shortcut: keysModel.get(getIndex("View.Single")).shortcut
    }
    Action {
        id: actionGridView
        onTriggered: buttonText1.checked = true
        shortcut: keysModel.get(getIndex("View.Grid")).shortcut
    }
    Action {
        id: actionMapView
        onTriggered: buttonText2.checked = true
        shortcut: keysModel.get(getIndex("View.Map")).shortcut
    }
    Action {
        id: actionCalibrate
        onTriggered: buttonCalibrate.checked = true
        shortcut: keysModel.get(getIndex("View.Calibration")).shortcut
    }
    Action {
        id: actionViewSettings
        onTriggered: {
            settingspage.initSettings()
            dgSettings.open()
        }
        shortcut: keysModel.get(getIndex("View.Settings")).shortcut
    }

    Action {
        id: actionSingleCapture
        shortcut: keysModel.get(getIndex("Single.SingleCapture")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.singleCapture()
    }
    Action {
        id: actionCountCapture
        shortcut: keysModel.get(getIndex("Single.CountCapture")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.countCapture()
    }
    Action {
        id: actionCountIntervalUp
        shortcut: keysModel.get(getIndex("Single.CountIntervalUp")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.countIntervalUp()
    }
    Action {
        id: actionCountIntervalDown
        shortcut: keysModel.get(getIndex("Single.CountIntervalDown")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.countIntervalDown()
    }
    Action {
        id: actionCountUp
        shortcut: keysModel.get(getIndex("Single.CountUp")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.countUp()
    }
    Action {
        id: actionCountDown
        shortcut: keysModel.get(getIndex("Single.CountDown")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.countDown()
    }
    Action {
        id: actionDurationCapture
        shortcut: keysModel.get(getIndex("Single.DurationCapture")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.durationCapture()
    }
    Action {
        id: actionDurationIntervalUp
        shortcut: keysModel.get(getIndex("Single.DurationIntervalUp")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.durIntervalUp()
    }
    Action {
        id: actionDurationIntervalDown
        shortcut: keysModel.get(getIndex("Single.DurationIntervalDown")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.durIntervalDown()
    }
    Action {
        id: actionDurationUp
        shortcut: keysModel.get(getIndex("Single.DurationUp")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.durationUp()
    }
    Action {
        id: actionDurationDown
        shortcut: keysModel.get(getIndex("Single.DurationDown")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.durationDown()
    }
    Action {
        id: actionStartRecording
        shortcut: keysModel.get(getIndex("Single.StartRecording")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.startRecording()
    }
    Action {
        id: actionPauseRecording
        shortcut: keysModel.get(getIndex("Single.PauseRecording")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.pauseRecording()
    }
    Action {
        id: actionStopRecording
        shortcut: keysModel.get(getIndex("Single.StopRecording")).shortcut
        enabled: viewerRibbon.visible
        onTriggered: viewerRibbon.stopRecording()
    }

    Action {
        id: actionGridSelectUp
        shortcut: keysModel.get(getIndex("Grid.SelectUp")).shortcut
        enabled: gridRibbon.visible
        onTriggered: cammodel.selectUp()
    }
    Action {
        id: actionGridSelectRight
        shortcut: keysModel.get(getIndex("Grid.SelectRight")).shortcut
        enabled: gridRibbon.visible
        onTriggered: cammodel.selectRight()
    }
    Action {
        id: actionGridSelectDown
        shortcut: keysModel.get(getIndex("Grid.SelectDown")).shortcut
        enabled: gridRibbon.visible
        onTriggered: cammodel.selectDown()
    }
    Action {
        id: actionGridSelectLeft
        shortcut: keysModel.get(getIndex("Grid.SelectLeft")).shortcut
        enabled: gridRibbon.visible
        onTriggered: cammodel.selectLeft()
    }
    Action {
        id: actionGridShiftUp
        shortcut: keysModel.get(getIndex("Grid.ShiftUp")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridcontent.shiftUp()
    }
    Action {
        id: actionGridShiftRight
        shortcut: keysModel.get(getIndex("Grid.ShiftRight")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridcontent.shiftRight()
    }
    Action {
        id: actionGridShiftDown
        shortcut: keysModel.get(getIndex("Grid.ShiftDown")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridcontent.shiftDown()
    }
    Action {
        id: actionGridShiftLeft
        shortcut: keysModel.get(getIndex("Grid.ShiftLeft")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridcontent.shiftLeft()
    }
    Action {
        id: actionGridMoveToSelected
        shortcut: keysModel.get(getIndex("Grid.MoveToSelected")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.moveToSelected()
    }
    Action {
        id: actionGridFillSelection
        shortcut: keysModel.get(getIndex("Grid.FillSelection")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.fillSelected()
    }
    Action {
        id: actionGridAutoFill
        shortcut: keysModel.get(getIndex("Grid.AutoFill")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.autoFill()
    }
    Action {
        id: actionGridSaveSelected
        shortcut: keysModel.get(getIndex("Grid.SaveSelected")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.saveSelected()
    }
    Action {
        id: actionGridSaveAll
        shortcut: keysModel.get(getIndex("Grid.SaveAll")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.saveAll()
    }
    Action {
        id: actionGridClearSelected
        shortcut: keysModel.get(getIndex("Grid.ClearSelected")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.clearSelected()
    }
    Action {
        id: actionGridInvertClear
        shortcut: keysModel.get(getIndex("Grid.InvertClear")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.invertClear()
    }
    Action {
        id: actionGridClearBuffers
        shortcut: keysModel.get(getIndex("Grid.ClearBuffers")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.clearAll()
    }
    Action {
        id: actionGridEnlarge
        shortcut: keysModel.get(getIndex("Grid.Enlarge")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.enlargeCells()
    }
    Action {
        id: actionGridShrink
        shortcut: keysModel.get(getIndex("Grid.Shrink")).shortcut
        enabled: gridRibbon.visible
        onTriggered: gridRibbon.shrinkCells()
    }

    Action {
        id: actionMapStartCapture
        shortcut: keysModel.get(getIndex("Map.StartCapture")).shortcut
        enabled: mapRibbon.visible
        onTriggered: mapRibbon.capture()
    }
    Action {
        id: actionMapMarkPoint1
        shortcut: keysModel.get(getIndex("Map.MarkPoint1")).shortcut
        enabled: mapRibbon.visible
        onTriggered: {
            var chk = atlas.setPt1()
            if (chk) mapcontent.popMark1()
        }
    }
    Action {
        id: actionMapMarkPoint2
        shortcut: keysModel.get(getIndex("Map.MarkPoint2")).shortcut
        enabled: mapRibbon.visible
        onTriggered: {
            var chk = atlas.setPt2()
            if (chk) mapcontent.popMark2()
        }
    }
    Action {
        id: actionMapMarkPoint3
        shortcut: keysModel.get(getIndex("Map.MarkPoint3")).shortcut
        enabled: mapRibbon.visible
        onTriggered: {
            var chk = atlas.setPt3()
            if (chk) mapcontent.popMark3()
        }
    }
    Action {
        id: actionMapMarkPoint4
        shortcut: keysModel.get(getIndex("Map.MarkPoint4")).shortcut
        enabled: mapRibbon.visible
        onTriggered: {
            var chk = atlas.setPt4()
            if (chk) mapcontent.popMark4()
        }
    }

    Component.onDestruction: {
        profilemenu.visible = false
        dgProfile.visible = false
        dgSettings.visible = false
    }
}

