/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.MultiVehicleManager
import QGroundControl.Palette

Rectangle {
    id:             __mavlinkRoot
    color:          "transparent"       // the settings frame behind shows through, like the other pages
    anchors.fill:   parent

    property int  _selectedCount:       0
    property real _columnSpacing:       ScreenTools.defaultFontPixelHeight * 0.25
    property bool _uploadedSelected:    false
    property bool _showMavlinkLog:      QGroundControl.corePlugin.options.showPX4LogTransferOptions
    property bool _showAPMStreamRates:  QGroundControl.apmFirmwareSupported && QGroundControl.settingsManager.apmMavlinkStreamRateSettings.visible && _isAPM
    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property bool _isPX4:               _activeVehicle ? _activeVehicle.px4Firmware : true
    property bool _isAPM:               _activeVehicle ? _activeVehicle.apmFirmware : true
    property Fact _disableDataPersistenceFact: QGroundControl.settingsManager.appSettings.disableAllPersistence
    property bool _disableDataPersistence:     _disableDataPersistenceFact ? _disableDataPersistenceFact.rawValue : false
    property var  _mavlinkLogManager:   _activeVehicle ? _activeVehicle.mavlinkLogManager : null
    readonly property bool _light:      qgcPal.globalTheme === QGCPalette.Light

    // Safe values when no vehicle (so no log manager) is connected
    readonly property bool _haveMgr:        !!_mavlinkLogManager
    readonly property bool _logRunning:     _haveMgr ? _mavlinkLogManager.logRunning : false
    readonly property bool _logUploading:   _haveMgr ? _mavlinkLogManager.uploading  : false
    readonly property bool _canStartLog:    _haveMgr ? _mavlinkLogManager.canStartLog : false

    // Layout: Logging full width on top; Log Uploads and Saved Log Files side by side below
    readonly property real _gap:        ScreenTools.defaultFontPixelHeight * 1.3        // gap between the boxes (both directions)
    readonly property real _boxPadY:    ScreenTools.defaultFontPixelHeight * 0.9   // space above and below the white inner box
    readonly property real _sectionW:   Math.min(__mavlinkRoot.width - ScreenTools.defaultFontPixelWidth * 4, ScreenTools.defaultFontPixelWidth * 200)
    readonly property bool _twoCol:     __mavlinkRoot.width - ScreenTools.defaultFontPixelWidth * 4 >= ScreenTools.defaultFontPixelWidth * 110
    readonly property real _halfW:      Math.floor((_sectionW - _gap) / 2)
    readonly property real _lowerW:     _twoCol ? _halfW : _sectionW

    // usable width inside the inner box of the two lower cards; labels and fields share it half and half
    readonly property real _innerW:     _lowerW - 12 - ScreenTools.defaultFontPixelWidth * 4
    property real _labelWidth:          Math.min(ScreenTools.defaultFontPixelWidth * 28, _innerW * 0.5)
    property real _valueWidth:          Math.min(ScreenTools.defaultFontPixelWidth * 24, _innerW * 0.5 - ScreenTools.defaultFontPixelWidth)

    // same colors as the cards on the General page
    readonly property color _cOuter:    _light ? "#F5F5F5" : "#404040"
    readonly property color _cInner:    _light ? "#FFFFFF" : "#202020"
    readonly property color _cLine:     _light ? "#E8E8E8" : "#606060"
    readonly property color _cEdge:     _light ? "#D6D7DC" : "#2A394A"
    readonly property color _cWell:     _light ? "#FAFAFA" : "#181818"

    // the two lower inner boxes share one, taller height
    readonly property real _lowerInnerH: Math.max(logColumn.height, logFilesColumn.height) + ScreenTools.defaultFontPixelHeight * 4

    // heading size follows the settings font size (if that setting exists)
    readonly property real _bump:       (typeof mainWindow !== "undefined" && mainWindow.settingsFontBump !== undefined) ? mainWindow.settingsFontBump : 0

    QGCPalette { id: qgcPal }

    Connections {
        target: _mavlinkLogManager
        onSelectedCountChanged: {
            _uploadedSelected = false
            var selected = 0
            for(var i = 0; i < _mavlinkLogManager.logFiles.count; i++) {
                var logFile = _mavlinkLogManager.logFiles.get(i)
                if(logFile.selected) {
                    selected++
                    //-- If an uploaded file is selected, disable "Upload" button
                    if(logFile.uploaded) {
                        _uploadedSelected = true
                    }
                }
            }
            _selectedCount = selected
        }
    }

    function saveItems() {
        if (!_mavlinkLogManager) {
            return
        }
        _mavlinkLogManager.videoURL = videoUrlField.text
        _mavlinkLogManager.feedback = feedbackTextArea.text
        _mavlinkLogManager.emailAddress = emailField.text
        _mavlinkLogManager.description = descField.text
        _mavlinkLogManager.uploadURL = urlField.text
        _mavlinkLogManager.emailAddress = emailField.text
        if(autoUploadCheck.checked && _mavlinkLogManager.emailAddress === "") {
            autoUploadCheck.checked = false
        } else {
            _mavlinkLogManager.enableAutoUpload = autoUploadCheck.checked
        }
    }

    MessageDialog {
        id:         emptyEmailDialog
        visible:    false
        //icon:       StandardIcon.Warning
        buttons:    MessageDialog.Close
        title:      qsTr("MAVLink Logging")
        text:       qsTr("Please enter an email address before uploading MAVLink log files.")
    }

    QGCFlickable {
        id:                 flick
        clip:               true
        anchors.fill:       parent
        anchors.margins:    ScreenTools.defaultFontPixelWidth
        contentHeight:      settingsColumn.height
        contentWidth:       width
        flickableDirection: Flickable.VerticalFlick

        Column {
            id:             settingsColumn
            width:          flick.width
            topPadding:     Math.max(24, Math.min(64, __mavlinkRoot.height * 0.06))
            bottomPadding:  ScreenTools.defaultFontPixelHeight * 2
            spacing:        _gap

            // Flow puts each card on its own line, or two side by side if they fit
            Flow {
                id:         sectionFlow
                x:          (flick.width - _sectionW) / 2
                width:      _sectionW
                spacing:    _gap

                //=============================================================
                //== Card 1: MAVLink Logging
                //=============================================================
                Rectangle {
                    id:             card1
                    width:          _sectionW
                    height:         box1.y + box1.height + _boxPadY
                    radius:         20
                    color:          _cOuter
                    border.color:   _cEdge
                    border.width:   1
                    visible:        _showMavlinkLog && _isPX4

                    Item {
                        x:          16
                        y:          14
                        width:      parent.width - 32
                        height:     mavlogLabel.height
                        QGCLabel {
                            id:             mavlogLabel
                            text:           qsTr("MAVLink 2.0 Logging (PX4 Pro Only)")
                            font.bold:      true
                            font.pointSize: ScreenTools.defaultFontPointSize + 3 + _bump
                        }
                    }

                    Rectangle {
                        id:             box1
                        x:              6
                        y:              14 + mavlogLabel.height + _boxPadY
                        width:          parent.width - 12
                        height:         mavlogColumn.height + (ScreenTools.defaultFontPixelHeight * 2)
                        radius:         14
                        color:          _cInner
                        border.color:   _cLine
                        border.width:   _light ? 0 : 1

                        Column {
                            id:         mavlogColumn
                            spacing:    _columnSpacing * 3
                            anchors.centerIn: parent
                            //-----------------------------------------------------------------
                            //-- Manual Start/Stop
                            Row {
                                spacing:    ScreenTools.defaultFontPixelWidth * 1.5
                                anchors.horizontalCenter: parent.horizontalCenter
                                QGCLabel {
                                    text:               qsTr("Manual Start/Stop:")
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                QGCButton {
                                    text:               qsTr("Start Logging")
                                    enabled:            !_logRunning && _canStartLog && !_disableDataPersistence
                                    onClicked:          _mavlinkLogManager.startLogging()
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                QGCButton {
                                    text:               qsTr("Stop Logging")
                                    enabled:            _logRunning && !_disableDataPersistence
                                    onClicked:          _mavlinkLogManager.stopLogging()
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Enable auto log on arming
                            QGCCheckBox {
                                text:       qsTr("Enable automatic logging")
                                checked:    _haveMgr ? _mavlinkLogManager.enableAutoStart : false
                                enabled:    _haveMgr && !_disableDataPersistence
                                onClicked: {
                                    _mavlinkLogManager.enableAutoStart = checked
                                }
                            }
                        }
                    }
                }

                //=============================================================
                //== Card 2: MAVLink Log Uploads
                //=============================================================
                Rectangle {
                    id:             card2
                    width:          _lowerW
                    height:         box2.y + box2.height + _boxPadY
                    radius:         20
                    color:          _cOuter
                    border.color:   _cEdge
                    border.width:   1
                    visible:        _showMavlinkLog && _isPX4

                    Item {
                        x:          16
                        y:          14
                        width:      parent.width - 32
                        height:     logLabel.height
                        QGCLabel {
                            id:             logLabel
                            text:           qsTr("MAVLink 2.0 Log Uploads (PX4 Pro Only)")
                            font.bold:      true
                            font.pointSize: ScreenTools.defaultFontPointSize + 3 + _bump
                        }
                    }

                    Rectangle {
                        id:             box2
                        x:              6
                        y:              14 + logLabel.height + _boxPadY
                        width:          parent.width - 12
                        height:         _lowerInnerH
                        radius:         14
                        color:          _cInner
                        border.color:   _cLine
                        border.width:   _light ? 0 : 1

                        Column {
                            id:         logColumn
                            spacing:    _columnSpacing
                            anchors.centerIn: parent
                            //-----------------------------------------------------------------
                            //-- Email address Field
                            Row {
                                spacing:    ScreenTools.defaultFontPixelWidth
                                QGCLabel {
                                    width:              _labelWidth
                                    elide:              Text.ElideRight
                                    anchors.baseline:   emailField.baseline
                                    text:               qsTr("Email address for Log Upload:")
                                }
                                QGCTextField {
                                    id:         emailField
                                    text:       _haveMgr ? _mavlinkLogManager.emailAddress : ""
                                    width:      _valueWidth
                                    enabled:    _haveMgr && !_disableDataPersistence
                                    inputMethodHints:       Qt.ImhNoAutoUppercase | Qt.ImhEmailCharactersOnly
                                    anchors.verticalCenter: parent.verticalCenter
                                    onEditingFinished: {
                                        saveItems();
                                    }
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Description Field
                            Row {
                                spacing:    ScreenTools.defaultFontPixelWidth
                                QGCLabel {
                                    width:              _labelWidth
                                    elide:              Text.ElideRight
                                    anchors.baseline:   descField.baseline
                                    text:               qsTr("Default Description:")
                                }
                                QGCTextField {
                                    id:         descField
                                    text:       _haveMgr ? _mavlinkLogManager.description : ""
                                    width:      _valueWidth
                                    enabled:    _haveMgr && !_disableDataPersistence
                                    anchors.verticalCenter: parent.verticalCenter
                                    onEditingFinished: {
                                        saveItems();
                                    }
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Upload URL
                            Row {
                                spacing:    ScreenTools.defaultFontPixelWidth
                                QGCLabel {
                                    width:              _labelWidth
                                    elide:              Text.ElideRight
                                    anchors.baseline:   urlField.baseline
                                    text:               qsTr("Default Upload URL")
                                }
                                QGCTextField {
                                    id:         urlField
                                    text:       _haveMgr ? _mavlinkLogManager.uploadURL : ""
                                    width:      _valueWidth
                                    enabled:    _haveMgr && !_disableDataPersistence
                                    inputMethodHints:       Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                                    anchors.verticalCenter: parent.verticalCenter
                                    onEditingFinished: {
                                        saveItems();
                                    }
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Video URL
                            Row {
                                spacing:    ScreenTools.defaultFontPixelWidth
                                QGCLabel {
                                    width:              _labelWidth
                                    elide:              Text.ElideRight
                                    anchors.baseline:   videoUrlField.baseline
                                    text:               qsTr("Video URL:")
                                }
                                QGCTextField {
                                    id:         videoUrlField
                                    text:       _haveMgr ? _mavlinkLogManager.videoURL : ""
                                    width:      _valueWidth
                                    enabled:    _haveMgr && !_disableDataPersistence
                                    inputMethodHints:       Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Wind Speed
                            Row {
                                spacing:                ScreenTools.defaultFontPixelWidth
                                QGCLabel {
                                    width:              _labelWidth
                                    elide:              Text.ElideRight
                                    anchors.baseline:   windCombo.baseline
                                    text:               qsTr("Wind Speed:")
                                }
                                QGCComboBox {
                                    id:         windCombo
                                    width:      _valueWidth
                                    enabled:    _haveMgr && !_disableDataPersistence
                                    textRole:   "text"
                                    model: ListModel {
                                        id: windItems
                                        ListElement { text: qsTr("Please Select"); value: -1 }
                                        ListElement { text: qsTr("Calm");     value: 0 }
                                        ListElement { text: qsTr("Breeze");   value: 5 }
                                        ListElement { text: qsTr("Gale");     value: 8 }
                                        ListElement { text: qsTr("Storm");    value: 10 }
                                    }
                                    onActivated: (index) => {
                                        saveItems();
                                        _mavlinkLogManager.windSpeed = windItems.get(index).value
                                        //console.log('Set Wind: ' + windItems.get(index).value)
                                    }
                                    Component.onCompleted: {
                                        if (!_mavlinkLogManager) {
                                            return
                                        }
                                        for(var i = 0; i < windItems.count; i++) {
                                            if(windItems.get(i).value === _mavlinkLogManager.windSpeed) {
                                                windCombo.currentIndex = i;
                                                //console.log('Wind: ' + windItems.get(i).value)
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Flight Rating
                            Row {
                                spacing:                ScreenTools.defaultFontPixelWidth
                                QGCLabel {
                                    width:              _labelWidth
                                    elide:              Text.ElideRight
                                    anchors.baseline:   ratingCombo.baseline
                                    text:               qsTr("Flight Rating:")
                                }
                                QGCComboBox {
                                    id:         ratingCombo
                                    width:      _valueWidth
                                    enabled:    _haveMgr && !_disableDataPersistence
                                    textRole:   "text"
                                    model: ListModel {
                                        id: ratingItems
                                        ListElement { text: qsTr("Please Select");            value: "notset"}
                                        ListElement { text: qsTr("Crashed (Pilot Error)");    value: "crash_pilot" }
                                        ListElement { text: qsTr("Crashed (Software or Hardware issue)");   value: "crash_sw_hw" }
                                        ListElement { text: qsTr("Unsatisfactory");           value: "unsatisfactory" }
                                        ListElement { text: qsTr("Good");                     value: "good" }
                                        ListElement { text: qsTr("Great");                    value: "great" }
                                    }
                                    onActivated: (index) => {
                                        saveItems();
                                        _mavlinkLogManager.rating = ratingItems.get(index).value
                                        //console.log('Set Rating: ' + ratingItems.get(index).value)
                                    }
                                    Component.onCompleted: {
                                        if (!_mavlinkLogManager) {
                                            return
                                        }
                                        for(var i = 0; i < ratingItems.count; i++) {
                                            if(ratingItems.get(i).value === _mavlinkLogManager.rating) {
                                                ratingCombo.currentIndex = i;
                                                //console.log('Rating: ' + ratingItems.get(i).value)
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Feedback
                            Row {
                                spacing:                ScreenTools.defaultFontPixelWidth
                                QGCLabel {
                                    width:              _labelWidth
                                    elide:              Text.ElideRight
                                    text:               qsTr("Additional Feedback:")
                                }
                                TextArea {
                                    id:                 feedbackTextArea
                                    width:              _valueWidth
                                    height:             ScreenTools.defaultFontPixelHeight * 4
                                    font.pointSize:     ScreenTools.defaultFontPointSize
                                    text:               _haveMgr ? _mavlinkLogManager.feedback : ""
                                    enabled:            _haveMgr && !_disableDataPersistence
                                    color:              qgcPal.textFieldText
                                    background:         Rectangle {
                                        color:          qgcPal.textField
                                        radius:         6
                                        border.color:   _cLine
                                        border.width:   1
                                    }
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Public Log
                            QGCCheckBox {
                                text:       qsTr("Make this log publicly available")
                                checked:    _haveMgr ? _mavlinkLogManager.publicLog : false
                                enabled:    _haveMgr && !_disableDataPersistence
                                onClicked: {
                                    _mavlinkLogManager.publicLog = checked
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Automatic Upload
                            QGCCheckBox {
                                id:         autoUploadCheck
                                text:       qsTr("Enable automatic log uploads")
                                checked:    _haveMgr ? _mavlinkLogManager.enableAutoUpload : false
                                enabled:    _haveMgr && !_disableDataPersistence
                                onClicked: {
                                    saveItems();
                                    if(checked && _mavlinkLogManager.emailAddress === "")
                                        emptyEmailDialog.open()
                                }
                            }
                            //-----------------------------------------------------------------
                            //-- Delete log after upload
                            QGCCheckBox {
                                text:       qsTr("Delete log file after uploading")
                                checked:    _haveMgr ? _mavlinkLogManager.deleteAfterUpload : false
                                enabled:    autoUploadCheck.checked && _haveMgr && !_disableDataPersistence
                                onClicked: {
                                    _mavlinkLogManager.deleteAfterUpload = checked
                                }
                            }
                        }
                    }
                }

                //=============================================================
                //== Card 3: Saved Log Files
                //=============================================================
                Rectangle {
                    id:             card3
                    width:          _lowerW
                    height:         box3.y + box3.height + _boxPadY
                    radius:         20
                    color:          _cOuter
                    border.color:   _cEdge
                    border.width:   1
                    visible:        _showMavlinkLog

                    Item {
                        x:          16
                        y:          14
                        width:      parent.width - 32
                        height:     logFilesLabel.height
                        QGCLabel {
                            id:             logFilesLabel
                            text:           qsTr("Saved Log Files")
                            font.bold:      true
                            font.pointSize: ScreenTools.defaultFontPointSize + 3 + _bump
                        }
                    }

                    Rectangle {
                        id:             box3
                        x:              6
                        y:              14 + logFilesLabel.height + _boxPadY
                        width:          parent.width - 12
                        height:         _lowerInnerH
                        radius:         14
                        color:          _cInner
                        border.color:   _cLine
                        border.width:   _light ? 0 : 1

                        Column {
                            id:         logFilesColumn
                            spacing:    _columnSpacing * 4
                            anchors.centerIn: parent
                            width:      Math.min(ScreenTools.defaultFontPixelWidth * 90, parent.width - ScreenTools.defaultFontPixelWidth * 4)

                            // list of log files
                            Rectangle {
                                width:          parent.width
                                height:         ScreenTools.defaultFontPixelHeight * 18
                                radius:         10
                                color:          _cWell
                                border.color:   _cLine
                                border.width:   1

                                QGCListView {
                                    anchors.fill:       parent
                                    anchors.margins:    ScreenTools.defaultFontPixelWidth
                                    orientation:        ListView.Vertical
                                    model:              _haveMgr ? _mavlinkLogManager.logFiles : null
                                    clip:               true
                                    delegate: Rectangle {
                                        width:          ListView.view.width
                                        height:         selectCheck.height
                                        color:          "transparent"

                                        property real _sizeW: ScreenTools.defaultFontPixelWidth * 18

                                        Row {
                                            width:                  parent.width
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing:                ScreenTools.defaultFontPixelWidth
                                            QGCCheckBox {
                                                id:         selectCheck
                                                width:      ScreenTools.defaultFontPixelWidth * 4
                                                checked:    object.selected
                                                enabled:    !object.writing && !object.uploading
                                                anchors.verticalCenter: parent.verticalCenter
                                                onClicked:  {
                                                    object.selected = checked
                                                }
                                            }
                                            QGCLabel {
                                                text:       object.name
                                                width:      Math.max(0, parent.width - selectCheck.width - _sizeW - parent.spacing * 2)
                                                elide:      Text.ElideRight
                                                color:      object.writing ? qgcPal.warningText : qgcPal.text
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            QGCLabel {
                                                text:       Number(object.size).toLocaleString(Qt.locale(), 'f', 0)
                                                visible:    !object.uploading && !object.uploaded
                                                width:      _sizeW
                                                color:      object.writing ? qgcPal.warningText : qgcPal.text
                                                horizontalAlignment: Text.AlignRight
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            QGCLabel {
                                                text:       qsTr("Uploaded")
                                                visible:    object.uploaded
                                                width:      _sizeW
                                                horizontalAlignment: Text.AlignRight
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            ProgressBar {
                                                visible:    object.uploading && !object.uploaded
                                                width:      _sizeW
                                                height:     ScreenTools.defaultFontPixelHeight
                                                anchors.verticalCenter: parent.verticalCenter
                                                from:       0
                                                to:         100
                                                value:      object.progress * 100.0
                                            }
                                        }
                                    }
                                }
                            }

                            // buttons
                            Flow {
                                width:      parent.width
                                spacing:    ScreenTools.defaultFontPixelWidth
                                QGCButton {
                                    text:       qsTr("Check All")
                                    enabled:    _haveMgr && !_logUploading && !_logRunning
                                    onClicked: {
                                        for(var i = 0; i < _mavlinkLogManager.logFiles.count; i++) {
                                            var logFile = _mavlinkLogManager.logFiles.get(i)
                                            logFile.selected = true
                                        }
                                    }
                                }
                                QGCButton {
                                    text:       qsTr("Check None")
                                    enabled:    _haveMgr && !_logUploading && !_logRunning
                                    onClicked: {
                                        for(var i = 0; i < _mavlinkLogManager.logFiles.count; i++) {
                                            var logFile = _mavlinkLogManager.logFiles.get(i)
                                            logFile.selected = false
                                        }
                                    }
                                }
                                QGCButton {
                                    text:       qsTr("Delete Selected")
                                    enabled:    _haveMgr && _selectedCount > 0 && !_logUploading && !_logRunning
                                    onClicked:  deleteDialog.open()
                                    MessageDialog {
                                        id:         deleteDialog
                                        visible:    false
                                        //icon:       StandardIcon.Warning
                                        buttons:    MessageDialog.Yes | MessageDialog.No
                                        title:      qsTr("Delete Selected Log Files")
                                        text:       qsTr("Confirm deleting selected log files?")
                                        onButtonClicked: function (button, role) {
                                            switch (button) {
                                            case MessageDialog.Yes:
                                                _mavlinkLogManager.deleteLog()
                                                break;
                                            }
                                        }
                                    }
                                }
                                QGCButton {
                                    text:       qsTr("Upload Selected")
                                    enabled:    _haveMgr && _selectedCount > 0 && !_logUploading && !_logRunning && !_uploadedSelected
                                    visible:    !_logUploading
                                    onClicked:  {
                                        saveItems();
                                        if(_mavlinkLogManager.emailAddress === "")
                                            emptyEmailDialog.open()
                                        else
                                            uploadDialog.open()
                                    }
                                    MessageDialog {
                                        id:         uploadDialog
                                        visible:    false
                                        //icon:       StandardIcon.Question
                                        buttons:    MessageDialog.Yes | MessageDialog.No
                                        title:      qsTr("Upload Selected Log Files")
                                        text:       qsTr("Confirm uploading selected log files?")
                                        onButtonClicked: function (button, role) {
                                            switch (button) {
                                            case MessageDialog.Yes:
                                                _mavlinkLogManager.uploadLog()
                                                break;
                                            }
                                        }
                                    }
                                }
                                QGCButton {
                                    text:       qsTr("Cancel")
                                    enabled:    _logUploading && !_logRunning
                                    visible:    _logUploading
                                    onClicked:  cancelDialog.open()
                                    MessageDialog {
                                        id:         cancelDialog
                                        visible:    false
                                        //icon:       StandardIcon.Warning
                                        buttons:    MessageDialog.Yes | MessageDialog.No
                                        title:      qsTr("Cancel Upload")
                                        text:       qsTr("Confirm canceling the upload process?")
                                        onButtonClicked: function (button, role) {
                                            switch (button) {
                                            case MessageDialog.Yes:
                                                _mavlinkLogManager.cancelUpload()
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}