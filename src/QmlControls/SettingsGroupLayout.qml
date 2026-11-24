import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Palette



ColumnLayout {
    id:                 control    
    spacing:            _cardStyle ? 0 : _margins / 2
    Layout.fillWidth:   _cardStyle
    implicitWidth:      _contentLayout.implicitWidth + (_margins * 2)
    implicitHeight:     _contentLayout.implicitHeight + (_margins * 2)

    default property alias contentItem: _contentLayout.data

    property alias contentSpacing: _contentLayout.spacing

    property string defaultBorderColor  : QGroundControl.globalPalette.groupBorder
    property string outerBorderColor    : defaultBorderColor

    property string heading
    property string headingDescription
    property bool   showDividers:       true
    property bool   showBorder:         true

    property real _margins: ScreenTools.defaultFontPixelHeight / 2

    readonly property bool  _cardStyle: showBorder && (typeof mainWindow !== "undefined") && mainWindow.settingsPageOpen
    readonly property bool  _light:     QGroundControl.globalPalette.globalTheme === QGCPalette.Light
    readonly property color _cOuter:    _light ? "#F5F5F5" : "#404040"
    readonly property color _cInner:    _light ? "#FFFFFF" : "#202020"
    readonly property color _cLine:     _light ? "#E8E8E8" : "#606060"
    readonly property color _cEdge:     _light ? "#D6D7DC" : "#2A394A"

    // Same row height for every row in a card (Application Settings only).
    // To make rows taller or shorter, change only this number.
    readonly property real _rowH: ScreenTools.defaultFontPixelHeight * 1.4

    function _applyRowHeights() {
        for (var i = 0; i < _contentLayout.children.length; i++) {
            var row = _contentLayout.children[i]
            if (row && row.Layout)
                row.Layout.minimumHeight = _cardStyle ? _rowH : 0
        }
    }

    // Re-apply when the Application Settings page opens or closes
    Connections {
        target: (typeof mainWindow !== "undefined") ? mainWindow : null
        function onSettingsPageOpenChanged() { control._applyRowHeights() }
    }

    Component.onCompleted: _applyRowHeights()

    ColumnLayout {
        z:                      1
        Layout.fillWidth:       true
        Layout.leftMargin:      control._cardStyle ? 16 : _margins
        Layout.rightMargin:     control._cardStyle ? 16 : 0
        Layout.topMargin:       control._cardStyle ? 14 : 0
        Layout.bottomMargin:    control._cardStyle ? 10 : 0
        spacing:                control._cardStyle ? 2 : 0
        visible:                heading !== ""

        QGCLabel {
            text:           heading
            font.pointSize: ScreenTools.defaultFontPointSize + (control._cardStyle ? 3 : 1)
            font.bold:      true
        }

        QGCLabel {
            Layout.fillWidth:   true
            text:               headingDescription
            wrapMode:           Text.WordWrap
            font.pointSize:     ScreenTools.smallFontPointSize
            opacity:            control._cardStyle ? 0.6 : 1
            visible:            headingDescription !== ""
        }
    }

    Rectangle {
        id:                 outerRect
        Layout.fillWidth:   true
        Layout.leftMargin:  control._cardStyle ? 6 : 0
        Layout.rightMargin: control._cardStyle ? 6 : 0
        Layout.bottomMargin: control._cardStyle ? 12 : 0
        Layout.topMargin:   control._cardStyle && heading === "" ? 6 : 0
        implicitWidth:      _contentLayout.implicitWidth + (showBorder ? _margins * 2 : 0)
        implicitHeight:     _contentLayout.implicitHeight + (showBorder ? _margins * 2: 0)
        color:              control._cardStyle ? control._cInner : "transparent"
        border.color:       control._cardStyle ? control._cLine : outerBorderColor
        border.width:       control._cardStyle ? (control._light ? 0 : 1) : (showBorder ? 1 : 0)
        radius:             control._cardStyle ? 14 : ScreenTools.defaultFontPixelHeight / 2

        // gray outer card, sized from the white box so it always wraps heading + rows
        Rectangle {
            visible:        control._cardStyle
            z:              -2
            x:              -6
            y:              -outerRect.y
            width:          outerRect.width + 12
            height:         outerRect.y + outerRect.height + 12
            radius:         20
            color:          control._cOuter
            border.color:   control._cEdge
            border.width:   1
        }

        // soft shadow under the white box
        Rectangle {
            visible:                control._cardStyle
            z:                      -1
            anchors.fill:           parent
            anchors.topMargin:      2
            anchors.bottomMargin:   -2
            radius:                 parent.radius
            color:                  "#000000"
            opacity:                control._light ? 0.07 : 0.25
        }

        Repeater {
            model: showDividers? _contentLayout.children.length : 0

            Rectangle {
                x:                  showBorder ? _margins : 0
                y:                  _contentItem.y + _contentItem.height + _margins + (showBorder ? _margins : 0)
                width:              parent.width - (showBorder ? _margins * 2 : 0)
                height:             1
                color:              control._cardStyle ? control._cLine : QGroundControl.globalPalette.groupBorder
                visible:            _contentItem.visible &&
                                        _contentItem.width !== 0 && _contentItem.height !== 0 &&
                                        index < _contentLayout.children.length - 1

                property var _contentItem: _contentLayout.children[index]
            }
        }

 
        ColumnLayout {
            id:                 _contentLayout
            x:                  showBorder ? _margins : 0
            y:                  showBorder ? _margins : 0
            width:              parent.width - (showBorder ? _margins * 2 : 0)
            spacing:            _margins * 2
            onChildrenChanged:  control._applyRowHeights()
        }
    }
}
