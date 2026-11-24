/****************************************************************************
 *
 * (c) 2009-2019 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * @file
 *   @author Gus Grubba <gus@auterion.com>
 */

import QtQuick
import QtQuick.Controls

import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

Button {
    id:                             button
    autoExclusive:                  true

    background: Rectangle {
        anchors.fill:               parent
        color:                      qgcPal.buttonHighlight
        visible:                    (mouseArea.pressed || button.checked)
    }

    contentItem: Row {
        spacing:                    ScreenTools.defaultFontPixelWidth
        anchors.left:               button.left
        anchors.leftMargin:         ScreenTools.defaultFontPixelWidth
        anchors.verticalCenter:     button.verticalCenter
        Item {
            height:                 ScreenTools.defaultFontPixelHeight * 3
            width:                  1
        }
        QGCColoredImage {
            source: modelData.iconSource
            color: _cText
            width: Math.max(20, Math.round(24 * _root._u))
            height: width
            fillMode: Image.PreserveAspectFit
            }
        Label {
            id:                     _label
            visible:                text !== ""
            text:                   button.text
            color:                  qgcPal.buttonText
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    // Process hover events
    MouseArea {
        id:                         mouseArea
        anchors.fill:               parent
        onClicked:                  button.clicked()
    }
}
