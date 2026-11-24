import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QGroundControl.Palette
import QGroundControl.ScreenTools
/// Standard push button control:
///     If there is both an icon and text the icon will be to the left of the text
///     If icon only, icon will be centered
Button {
    id:             control
    hoverEnabled:   !ScreenTools.isMobile
    topPadding:     _settingsStyle ? 0 : _verticalPadding
    bottomPadding:  _settingsStyle ? 0 : _verticalPadding
    implicitHeight: _settingsStyle ? ScreenTools.defaultFontPixelHeight * 1.6 :
                    Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    leftPadding:    _horizontalPadding
    rightPadding:   _horizontalPadding
    focusPolicy:    Qt.ClickFocus
    font.family:    ScreenTools.normalFontFamily
    text:           ""
    property bool   primary:        false                               ///< primary button for a group of buttons
    // Application Settings page only: rounded-rectangle buttons (8 px radius)
    readonly property bool _settingsStyle: (typeof mainWindow !== "undefined") && mainWindow.settingsPageOpen
    property bool   showBorder:     _settingsStyle || qgcPal.globalTheme === QGCPalette.Light
    property real   backRadius:     _settingsStyle ? 8 : ScreenTools.buttonBorderRadius
    property real   heightFactor:   0.5
    property string iconSource:     ""
    property real   fontWeight:     Font.Normal // default for qml Text
    property real   pointSize:      ScreenTools.defaultFontPointSize
    property alias wrapMode:            text.wrapMode
    property alias horizontalAlignment: text.horizontalAlignment
    property alias backgroundColor:     backRect.color
    property alias textColor:           text.color
    property bool   _showHighlight:     enabled && (pressed | checked)
    // Application Settings dialogs only: solid fill (red Cancel, dark gray OK).
    // Default is transparent, so every other button looks exactly as before.
    property color  settingsFill:       "transparent"
    property color  settingsTextColor:  "#FFFFFF"
    readonly property bool _hasSettingsFill: _settingsStyle && settingsFill.a > 0
    // Application Settings page only: same colors as the sidebar (keep in sync with AppSettings.qml)
    readonly property color _setHover:  qgcPal.globalTheme === QGCPalette.Light ? "#E0E1E5" : "#222D3A"
    readonly property color _setPress:  qgcPal.globalTheme === QGCPalette.Light ? "#D1D2D8" : "#2E3B4B"
    property int _horizontalPadding:    ScreenTools.defaultFontPixelWidth * 2
    property int _verticalPadding:      Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)
    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    background: Rectangle {
        id:             backRect
        radius:         backRadius
        implicitWidth:  ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        border.width:   showBorder ? 1 : 0
        border.color:   _hasSettingsFill ? settingsFill : ((_settingsStyle && qgcPal.globalTheme === QGCPalette.Dark) ? "#606060" : qgcPal.buttonBorder)
        color:          _hasSettingsFill ? settingsFill : (_settingsStyle ? (qgcPal.globalTheme === QGCPalette.Dark ? "#404040" : "#F1F3F8") : qgcPal.button)
        Rectangle {
            anchors.fill:   parent
            radius:         parent.radius
            color:          _hasSettingsFill ? "#000000" : (_settingsStyle ? (_showHighlight ? _setPress : _setHover) : qgcPal.buttonHighlight)
            opacity:        _hasSettingsFill ? ((_showHighlight || (control.enabled && control.hovered)) ? 0.15 : 0)
                            : (_settingsStyle ? ((_showHighlight || (control.enabled && control.hovered)) ? 1 : 0)
                                              : (_showHighlight ? 1 : control.enabled && control.hovered ? .2 : 0))
        }
    }
    contentItem: RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth
            QGCColoredImage {
                id:                     icon
                Layout.alignment:       Qt.AlignHCenter
                source:                 control.iconSource
                height:                 text.height
                width:                  height
                color:                  text.color
                fillMode:               Image.PreserveAspectFit
                sourceSize.height:      height
                visible:                control.iconSource !== ""
            }
            QGCLabel {
                id:                     text
                Layout.alignment:       Qt.AlignHCenter
                text:                   control.text
                font.pointSize:         control.pointSize
                font.family:            control.font.family
                font.weight:            fontWeight
                color:                  _hasSettingsFill ? settingsTextColor : ((_showHighlight && !_settingsStyle) ? qgcPal.buttonHighlightText : (primary ? qgcPal.primaryButtonText : qgcPal.buttonText))
                visible:                control.text !== ""
            }
    }
}