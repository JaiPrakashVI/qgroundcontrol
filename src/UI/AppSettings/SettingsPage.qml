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

Item {
    id: root

    default property alias contentItem: mainLayout.data

    // Application Settings page only: wide responsive column and a gap at the top
    readonly property bool  _settingsStyle: (typeof mainWindow !== "undefined") && mainWindow.settingsPageOpen
    readonly property real  _topGap:        _settingsStyle ? Math.max(24, Math.min(64, root.height * 0.06)) : 0
    readonly property real  _colWidth:      Math.max(ScreenTools.defaultFontPixelWidth * 50,
                                                     Math.min(root.width * 0.8, ScreenTools.defaultFontPixelWidth * 110))
    // Set true on a page (Plan settings) to use the full width of the settings area
    property bool   wideColumn:     false

    QGCFlickable {
        anchors.fill:   parent
        contentWidth:   mainLayout.width
        contentHeight:  mainLayout.height + root._topGap * 2

        ColumnLayout {
            id:         mainLayout
            x:          Math.max(0, root.width / 2 - width / 2)
            y:          root._topGap
            width:      root._settingsStyle ? (root.wideColumn ? Math.min(root.width - 48, ScreenTools.defaultFontPixelWidth * 200)
                                                                : Math.max(root._colWidth, implicitWidth))
                                            : Math.max(implicitWidth, ScreenTools.defaultFontPixelWidth * 50)
            spacing:    ScreenTools.defaultFontPixelHeight
        }
    }
}
