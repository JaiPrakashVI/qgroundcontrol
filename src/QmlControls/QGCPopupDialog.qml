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
import QtQuick.Layouts
import QtQuick.Dialogs
import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

Popup {
    id:                 root
    width:  mainWindow.width
    height: mainWindow.height
    parent:             Overlay.overlay
    modal:              true
    focus:              true
    margins:            0
    property string title
    property var    buttons:                Dialog.Ok
    property alias  acceptButtonEnabled:    acceptButton.enabled
    property alias  rejectButtonEnabled:    rejectButton.enabled
    property var    dialogProperties
    property bool   destroyOnClose:         true
    property bool   preventClose:           false

    // Application Settings page only: no dimmed layer over the page behind the dialog
    dim:                !_settingsLook

    readonly property real headerMinWidth: titleLable.implicitWidth + rejectButton.width + acceptButton.width + titleRowLayout.spacing * 2
    signal accepted
    signal rejected
    property var    _qgcPal:            QGroundControl.globalPalette
    // Application Settings page only: dialog look (colors from the settings design)
    readonly property bool  _settingsLook:  (typeof mainWindow !== "undefined") && mainWindow.settingsPageOpen
    readonly property bool  _settingsLight: _qgcPal.globalTheme === QGCPalette.Light
    readonly property color _cOuter:        _settingsLight ? "#F5F5F5" : "#404040"
    readonly property color _cInner:        _settingsLight ? "#FFFFFF" : "#202020"
    readonly property color _cLine:         _settingsLight ? "#E8E8E8" : "#606060"
    readonly property color _cEdge:         _settingsLight ? "#D6D7DC" : "#2A394A"
    property real   _frameSize:         ScreenTools.defaultFontPixelWidth
    property real   _contentMargin:     _settingsLook ? ScreenTools.defaultFontPixelHeight : ScreenTools.defaultFontPixelHeight / 2
    property bool   _acceptAllowed:     acceptButton.visible
    property bool   _rejectAllowed:     rejectButton.visible
    property int    _previousValidationErrorCount: 0
    background: QGCMouseArea {
        width:  mainWindow.width
        height: mainWindow.height
        onClicked: {
            if (closePolicy & Popup.CloseOnPressOutside) {
                _reject()
            }
        }
    }
    Component.onCompleted: {
        // The last child item will be the true dialog content.
        // Re-Parent it to the right place in the ui hierarchy.
        contentChildren[contentChildren.length - 1].parent = dialogContentParent
    }
    onAboutToShow: {
        _previousValidationErrorCount = globals.validationErrorCount
        setupDialogButtons(buttons)
    }
    onClosed: {
        globals.validationErrorCount = _previousValidationErrorCount
        Qt.inputMethod.hide()
        if (destroyOnClose) {
            root.destroy()
        }
    }
    function _accept() {
        if (_acceptAllowed && mainWindow.allowViewSwitch(_previousValidationErrorCount)) {
            accepted()
            if (preventClose) {
                preventClose = false
            } else {
                close()
            }
        }
    }
    function _reject() {
        // Dialogs with cancel button are allowed to close with validation errors
        if (_rejectAllowed && ((buttons & Dialog.Cancel) || mainWindow.allowViewSwitch(_previousValidationErrorCount))) {
            rejected()
            if (preventClose) {
                preventClose = false
            } else {
                close()
            }
        }
    }
    QGCPalette { id: qgcPal; colorGroupEnabled: parent.enabled }
    function setupDialogButtons(buttons) {
        acceptButton.visible = false
        rejectButton.visible = false
        // Accept role buttons
        if (buttons & Dialog.Ok) {
            acceptButton.text = qsTr("Ok")
            acceptButton.visible = true
        } else if (buttons & Dialog.Open) {
            acceptButton.text = qsTr("Open")
            acceptButton.visible = true
        } else if (buttons & Dialog.Save) {
            acceptButton.text = qsTr("Save")
            acceptButton.visible = true
        } else if (buttons & Dialog.Apply) {
            acceptButton.text = qsTr("Apply")
            acceptButton.visible = true
        } else if (buttons & Dialog.Open) {
            acceptButton.text = qsTr("Open")
            acceptButton.visible = true
        } else if (buttons & Dialog.SaveAll) {
            acceptButton.text = qsTr("Save All")
            acceptButton.visible = true
        } else if (buttons & Dialog.Yes) {
            acceptButton.text = qsTr("Yes")
            acceptButton.visible = true
        } else if (buttons & Dialog.YesToAll) {
            acceptButton.text = qsTr("Yes to All")
            acceptButton.visible = true
        } else if (buttons & Dialog.Retry) {
            acceptButton.text = qsTr("Retry")
            acceptButton.visible = true
        } else if (buttons & Dialog.Reset) {
            acceptButton.text = qsTr("Reset")
            acceptButton.visible = true
        } else if (buttons & Dialog.RestoreToDefaults) {
            acceptButton.text = qsTr("Restore to Defaults")
            acceptButton.visible = true
        } else if (buttons & Dialog.Ignore) {
            acceptButton.text = qsTr("Ignore")
            acceptButton.visible = true
        }
        // Reject role buttons
        if (buttons & Dialog.Cancel) {
            rejectButton.text = qsTr("Cancel")
            rejectButton.visible = true
        } else if (buttons & Dialog.Close) {
            rejectButton.text = qsTr("Close")
            rejectButton.visible = true
        } else if (buttons & Dialog.No) {
            rejectButton.text = qsTr("No")
            rejectButton.visible = true
        } else if (buttons & Dialog.NoToAll) {
            rejectButton.text = qsTr("No to All")
            rejectButton.visible = true
        } else if (buttons & Dialog.Abort) {
            rejectButton.text = qsTr("Abort")
            rejectButton.visible = true
        }
        closePolicy = Popup.NoAutoClose
        if (buttons & Dialog.Cancel) {
            closePolicy |= Popup.CloseOnEscape
        }
    }
    function disableAcceptButton() {
        acceptButton.enabled = false
    }

    // Application Settings page only: soft shadow all round the dialog panel.
    // Four layers, each a bit larger than the panel, placed BEFORE the panel so it covers them.
    // A small downward offset (+4) makes the shadow sit a little lower, like the mockup.
    Rectangle {
        visible:        _settingsLook
        x:              mainLayout.x - _contentMargin - 12
        y:              mainLayout.y - _contentMargin - 12 + 4
        width:          mainLayout.width + _contentMargin * 2 + 24
        height:         mainLayout.height + _contentMargin * 2 + 24
        radius:         32
        color:          "#000000"
        opacity:        0.025
    }
    Rectangle {
        visible:        _settingsLook
        x:              mainLayout.x - _contentMargin - 8
        y:              mainLayout.y - _contentMargin - 8 + 4
        width:          mainLayout.width + _contentMargin * 2 + 16
        height:         mainLayout.height + _contentMargin * 2 + 16
        radius:         28
        color:          "#000000"
        opacity:        0.035
    }
    Rectangle {
        visible:        _settingsLook
        x:              mainLayout.x - _contentMargin - 4
        y:              mainLayout.y - _contentMargin - 4 + 4
        width:          mainLayout.width + _contentMargin * 2 + 8
        height:         mainLayout.height + _contentMargin * 2 + 8
        radius:         24
        color:          "#000000"
        opacity:        0.05
    }
    Rectangle {
        visible:        _settingsLook
        x:              mainLayout.x - _contentMargin - 1
        y:              mainLayout.y - _contentMargin - 1 + 4
        width:          mainLayout.width + _contentMargin * 2 + 2
        height:         mainLayout.height + _contentMargin * 2 + 2
        radius:         21
        color:          "#000000"
        opacity:        0.07
    }

    Rectangle {
        x:              mainLayout.x - _contentMargin
        y:              mainLayout.y - _contentMargin
        width:          mainLayout.width + _contentMargin * 2
        height:         mainLayout.height + _contentMargin * 2
        color:          _settingsLook ? _cOuter : _qgcPal.windowShade
        radius:         _settingsLook ? 20 : root.padding / 2
        border.width:   1
        border.color:   _settingsLook ? _cEdge : _qgcPal.windowShadeLight
    }
    ColumnLayout {
        id:                 mainLayout
        anchors.centerIn:   parent
        x:          _contentMargin
        y:          _contentMargin
        spacing:    _contentMargin
        RowLayout {
            id:                     titleRowLayout
            Layout.fillWidth:       true
            spacing:                _contentMargin
            QGCLabel {
                id: titleLable
                Layout.fillWidth:   true
                text:               root.title
                font.pointSize:     ScreenTools.mediumFontPointSize
                font.bold:          _settingsLook
                verticalAlignment:  Text.AlignVCenter
            }
            // On the settings page these two buttons are hidden from the title row
            // (width 0, clipped). The full-width buttons below replace them.
            // Logic is unchanged: the buttons still hold the text and call _accept/_reject.
            QGCButton {
                id:                     rejectButton
                onClicked:              _reject()
                Layout.minimumWidth:    _settingsLook ? 0 : height * 1.5
                Layout.preferredWidth:  _settingsLook ? 0 : implicitWidth
                clip:                   _settingsLook
            }
            QGCButton {
                id:                     acceptButton
                primary:                true
                onClicked:              _accept()
                Layout.minimumWidth:    _settingsLook ? 0 : height * 1.5
                Layout.preferredWidth:  _settingsLook ? 0 : implicitWidth
                clip:                   _settingsLook
            }
        }
        // Application Settings page only: thin divider under the title
        Rectangle {
            visible:                _settingsLook
            Layout.fillWidth:       true
            Layout.preferredHeight: 1
            color:                  _cLine
        }
        Rectangle {
            Layout.fillWidth:       true
            Layout.preferredWidth:  Math.min(maxAvailableWidth, totalContentWidth)
            Layout.preferredHeight: Math.min(maxAvailableHeight, totalContentHeight)
            color:                  _settingsLook ? "transparent" : _qgcPal.window
            property real maxAvailableWidth:    mainWindow.width - _contentMargin * 4
            property real maxAvailableHeight:   mainWindow.height - titleRowLayout.height - _contentMargin * 5
            property real totalContentWidth:    dialogContentParent.childrenRect.width + _contentMargin * 2
            property real totalContentHeight:   dialogContentParent.childrenRect.height + _contentMargin * 2
            QGCFlickable {
                anchors.margins:    _contentMargin
                anchors.fill:       parent
                contentWidth:       dialogContentParent.childrenRect.width
                contentHeight:      dialogContentParent.childrenRect.height
                Item {
                    id:     dialogContentParent
                    focus:  true
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape && _rejectAllowed) {
                            _reject()
                            event.accepted = true
                        }
                    }
                }
            }
        }
        // Application Settings page only: full-width stacked buttons under the message
        ColumnLayout {
            visible:                _settingsLook
            Layout.fillWidth:       true
            spacing:                _contentMargin / 2
            QGCButton {
                Layout.fillWidth:       true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2
                visible:                acceptButton.visible
                enabled:                acceptButton.enabled
                text:                   acceptButton.text
                primary:                true
                settingsFill:           _settingsLight ? "#EBEBEB" : "#606060"
                settingsTextColor:      _settingsLight ? "#1F2328" : "#FFFFFF"
                onClicked:              _accept()
            }
            QGCButton {
                Layout.fillWidth:       true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2
                visible:                rejectButton.visible
                enabled:                rejectButton.enabled
                text:                   rejectButton.text
                // Light red for Cancel only. Other reject labels (No, Close) keep the normal look.
                settingsFill:           rejectButton.text === qsTr("Cancel") ? (_settingsLight ? "#FADBD8" : "#5C2B2B") : "transparent"
                settingsTextColor:      rejectButton.text === qsTr("Cancel") ? (_settingsLight ? "#D93025" : "#FF8A80") : (_settingsLight ? "#1F2328" : "#E6EAF0")
                onClicked:              _reject()
            }
        }
    }
}