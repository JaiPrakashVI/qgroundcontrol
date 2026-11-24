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

import QGroundControl.Palette
import QGroundControl.ScreenTools

AbstractButton   {
    id:             control
    checkable:      true
    padding:        0

    property bool   _showBorder: qgcPal.globalTheme === QGCPalette.Light

    // Application Settings page only (keep in sync with AppSettings.qml)
    readonly property bool  _settingsStyle: (typeof mainWindow !== "undefined") && mainWindow.settingsPageOpen
    readonly property bool  _isLight:       qgcPal.globalTheme === QGCPalette.Light
    readonly property color _setOn:         "#30d158"                         // on track (green), both themes
    readonly property color _setOff:        _isLight ? "#E4E4E4" : "#404040"  // off track
    readonly property color _setEdge:       _isLight ? "#CDCED4" : "#606060"  // track border
    readonly property color _setKnob:       "#FFFFFF"                         // knob fill
    readonly property color _setKnobEdge:   _isLight ? "#CDCED4" : "#808080"  // knob border
    readonly property color _setRing:       _isLight ? "#A0A0A0" : "#808080"  // off-state ring

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    contentItem: Item {
        implicitWidth:  (label.visible ? label.contentWidth + ScreenTools.defaultFontPixelWidth : 0) + indicator.width 
        implicitHeight: label.contentHeight

        // QGCLabel {
        //     id:             label
        //     anchors.left:   parent.left
        //     text:           visible ? control.text : "X"
        //     visible:        control.text !== ""
        // }

        QGCLabel {
            id:             label
            anchors.left:   parent.left
            y:              control._settingsStyle ? (parent.height - height) / 2 : 0
            text:           visible ? control.text : "X"
            visible:        control.text !== ""
        }
    
        Rectangle {
            id:                     indicator
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            height:                 ScreenTools.defaultFontPixelHeight
            width:                  height * 2
            radius:                 height / 2
            color:                  _settingsStyle ? (control.checked ? _setOn : _setOff)
                                                   : (control.checked ? qgcPal.primaryButton : qgcPal.button)
            border.width:           (_settingsStyle || _showBorder) ? 1 : 0
            border.color:           _settingsStyle ? _setEdge : qgcPal.buttonBorder

            // Off-state ring on the right side (settings page only)
            Rectangle {
                visible:                _settingsStyle && !control.checked
                anchors.verticalCenter: parent.verticalCenter
                anchors.right:          parent.right
                anchors.rightMargin:    parent.height * 0.3
                width:                  parent.height * 0.5
                height:                 width
                radius:                 width / 2
                color:                  "transparent"
                border.width:           2
                border.color:           _setRing
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x:                      checked ? indicator.width - width - 1: 1
                height:                 parent.height - 6
                width:                  indicator.width * 0.55
                radius:                 height * 0.35
                color:                  _settingsStyle ? _setKnob : qgcPal.buttonText
                border.width:           _settingsStyle ? 1 : 0
                border.color:           _setKnobEdge
            }
        }
    }
}
