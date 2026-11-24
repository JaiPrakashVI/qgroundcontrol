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

SettingsPage {
    id:page
    property var    _settingsManager:           QGroundControl.settingsManager
    property var    _appSettings:               _settingsManager.appSettings
    property var    _brandImageSettings:        _settingsManager.brandImageSettings
    property Fact   _appFontPointSize:          _appSettings.appFontPointSize
    property Fact   _userBrandImageIndoor:      _brandImageSettings.userBrandImageIndoor
    property Fact   _userBrandImageOutdoor:     _brandImageSettings.userBrandImageOutdoor
    property Fact   _appSavePath:               _appSettings.savePath

    readonly property real _cardW: Math.max(ScreenTools.defaultFontPixelWidth * 50,
                                            Math.min(page.width - 48, ScreenTools.defaultFontPixelWidth * 130))
    // two columns only when the page has room for two cards side by side
    readonly property bool _wide:  page.width - 48 >= ScreenTools.defaultFontPixelWidth * 110
    readonly property real _gridW: _wide ? Math.min(page.width - 48, ScreenTools.defaultFontPixelWidth * 200)
                                         : page._cardW
    // every row in every card gets at least this height, so all rows match
    readonly property real _rowH: ScreenTools.defaultFontPixelHeight * 1.4


    // Settings card: gray outer box (heading) + inner box (rows)
    component AppCard: Rectangle {
        id: card

        default property alias content: contentLayout.data
        property string heading:            ""
        property string headingDescription: ""
        property bool   showDividers:       true
        property real   targetWidth:        0

        readonly property bool  _light:  QGroundControl.globalPalette.globalTheme === QGCPalette.Light
        readonly property color _cOuter: _light ? "#F5F5F5" : "#404040"
        readonly property color _cInner: _light ? "#FFFFFF" : "#202020"
        readonly property color _cLine:  _light ? "#E8E8E8" : "#606060"
        readonly property color _cEdge:  _light ? "#D6D7DC" : "#2A394A"
        readonly property real  _m:      ScreenTools.defaultFontPixelHeight / 2

        Layout.fillWidth:   true
        implicitWidth:       Math.max(outerLayout.implicitWidth + 24, targetWidth)
        implicitHeight:     outerLayout.implicitHeight + 24
        radius:             20
        color:              _cOuter
        border.color:       _cEdge
        border.width:       1
        Layout.alignment:   Qt.AlignTop

        ColumnLayout {
            id:                 outerLayout
            anchors.fill:       parent
            anchors.margins:    6
            spacing:            0

            // Heading inside the outer box
            ColumnLayout {
                Layout.fillWidth:       true
                Layout.leftMargin:      10
                Layout.topMargin:       8
                Layout.bottomMargin:    10
                spacing:                2
                visible:                card.heading !== ""

                QGCLabel {
                    text:           card.heading
                    font.pointSize: ScreenTools.defaultFontPointSize + 3
                    font.bold:      true
                }

                QGCLabel {
                    Layout.fillWidth:   true
                    text:               card.headingDescription
                    wrapMode:           Text.WordWrap
                    font.pointSize:     ScreenTools.smallFontPointSize
                    opacity:            0.6
                    visible:            card.headingDescription !== ""
                }
            }

            // Inner box with the rows
            Rectangle {
                id:                 innerCard
                Layout.fillWidth:   true
                implicitWidth:      contentLayout.implicitWidth + card._m * 2
                implicitHeight:     contentLayout.implicitHeight + card._m * 2
                radius:             14
                color:              card._cInner
                border.color:       card._cLine
                border.width:       card._light ? 0 : 1

                // soft shadow under the inner box
                Rectangle {
                    z:                  -1
                    anchors.fill:       parent
                    anchors.topMargin:  2
                    anchors.bottomMargin: -2
                    radius:             parent.radius
                    color:              "#000000"
                    opacity:            card._light ? 0.07 : 0.25
                }

                // divider lines between rows
                Repeater {
                    model: card.showDividers ? contentLayout.children.length : 0

                    Rectangle {
                        x:          card._m
                        y:          contentLayout.y + _item.y + _item.height + card._m
                        width:      innerCard.width - card._m * 2
                        height:     1
                        color:      card._cLine
                        visible:    _item.visible && _item.width !== 0 && _item.height !== 0 &&
                                        index < contentLayout.children.length - 1

                        property var _item: contentLayout.children[index]
                    }
                }

                ColumnLayout {
                    id:         contentLayout
                    x:          card._m
                    y:          card._m
                    width:      innerCard.width - card._m * 2
                    spacing:    card._m * 2
                }
            }
        }
    }

    // Segmented option buttons: all options in one rounded bar, highlight slides to the chosen one

    component SegFact: Rectangle {
            id: seg
            property Fact fact: null
            readonly property var   _names: fact ? fact.enumStrings : []
            readonly property int   _count: _names ? _names.length : 0
            readonly property int   _cur:   fact ? fact.enumIndex : -1
            readonly property bool  _light: QGroundControl.globalPalette.globalTheme === QGCPalette.Light
            readonly property color _track: _light ? "#FFFFFF" : "#202020"   // same as the inner box
            readonly property color _edge:  _light ? "#E0E0E0" : "#606060"   // same as the pill border
            readonly property color _sel:   _light ? "#EBEBEB" : "#404040"   // same gray as the pill fill
            readonly property color _txtOn: _light ? "#1F2328" : "#E6EAF0"
            readonly property color _txtOff:_light ? "#6B7280" : "#A0A0A0"
            readonly property real  _pad:   4                                // gap between bar edge and highlight

            implicitWidth:  segRow.implicitWidth + _pad * 2
            implicitHeight: ScreenTools.defaultFontPixelHeight * 1.6
            radius:         10
            color:          _track
            border.color:   _edge
            border.width:   1

            // sliding highlight
            Rectangle {
                visible:    seg._cur >= 0 && seg._count > 0
                y:          seg._pad
                height:     seg.height - seg._pad * 2
                width:      segRow.width / Math.max(1, seg._count)
                x:          segRow.x + Math.max(0, seg._cur) * width
                radius:     6
                color:      seg._sel
                Behavior on x     { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }

            RowLayout {
                id:                 segRow
                x:                  seg._pad
                y:                  seg._pad
                height:             seg.height - seg._pad * 2
                spacing:            0
                uniformCellSizes:   true
                Repeater {
                    model: seg._names
                    Item {
                        Layout.fillWidth:   true
                        Layout.fillHeight:  true
                        implicitWidth:      segLabel.implicitWidth + ScreenTools.defaultFontPixelWidth * 5
                        QGCLabel {
                            id:             segLabel
                            anchors.centerIn: parent
                            text:           modelData
                            color:          index === seg._cur ? seg._txtOn : seg._txtOff
                            font.bold:      index === seg._cur
                        }
                        MouseArea {
                            anchors.fill:   parent
                            cursorShape:    Qt.PointingHandCursor
                            onClicked:      seg.fact.enumIndex = index
                        }
                    }
                }
            }
        }

    // One settings row: label on the left, option buttons on the right.
    // If the row is too narrow for the buttons, it falls back to the normal dropdown.
    component OptionRow: RowLayout {
        id: optRow
        property string label:  ""
        property Fact   fact:   null
        readonly property bool _fits: width >= rowLabel.implicitWidth + segCtl.implicitWidth + spacing
        Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 1.6
        Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
        Layout.fillWidth:   true
        spacing:            ScreenTools.defaultFontPixelWidth * 2
        visible:            fact ? fact.visible : true

        QGCLabel {
            id:                 rowLabel
            Layout.fillWidth:   true
            text:               optRow.label
        }
        SegFact {
            id:         segCtl
            visible:    optRow._fits
            fact:       optRow.fact
        }
        FactComboBox {
            visible:    !optRow._fits
            fact:       optRow.fact
            indexModel: false
        }
    }


    GridLayout {
        id:                     cardGrid
        Layout.fillWidth:       true
        Layout.preferredWidth:  page._gridW
        columns:                page._wide ? 2 : 1
        columnSpacing:          ScreenTools.defaultFontPixelWidth * 2
        rowSpacing:             ScreenTools.defaultFontPixelHeight

    AppCard {
        Layout.fillWidth:       true
        Layout.preferredWidth:  1
        heading:                qsTr("General")

        LabelledFactComboBox {
            label:      qsTr("Language")
            Layout.minimumHeight: page._rowH
            fact:       _appSettings.qLocaleLanguage
            indexModel: false
            visible:    _appSettings.qLocaleLanguage.visible
        }

        OptionRow {
            label:  qsTr("Color Scheme")
            fact:   _appSettings.indoorPalette
        }

        LabelledFactComboBox {
            label:       qsTr("Stream GCS Position")
            Layout.preferredHeight: page._rowH
            fact:       _appSettings.followTarget
            indexModel: false
            visible:    _appSettings.followTarget.visible
        }

        FactCheckBoxSlider {
            Layout.fillWidth: true
            Layout.preferredHeight: page._rowH
            text:           qsTr("Mute all audio output")
            fact:       _audioMuted
            visible:    _audioMuted.visible
            property Fact _audioMuted: _appSettings.audioMuted
        }

        FactCheckBoxSlider {
            Layout.fillWidth: true
            Layout.minimumHeight: page._rowH
            text:       qsTr("Save application data to SD Card")
            fact:       _androidSaveToSDCard
            visible:    _androidSaveToSDCard.visible
            property Fact _androidSaveToSDCard: _appSettings.androidSaveToSDCard
        }

        QGCCheckBoxSlider {
            Layout.fillWidth: true
            Layout.minimumHeight: page._rowH
            text:       qsTr("Clear all settings on next start")
            checked:    false
            onClicked: {
                if (checked) {
                    QGroundControl.deleteAllSettingsNextBoot()
                } else {
                    QGroundControl.clearDeleteAllSettingsNextBoot()
                }
            }
        }

        RowLayout {
            Layout.fillWidth:       true
            Layout.minimumHeight:   page._rowH
            spacing:                ScreenTools.defaultFontPixelWidth * 2
            visible:                _appFontPointSize.visible

            QGCLabel {
                Layout.fillWidth:   true
                text:               qsTr("UI Scaling")
            }

            Rectangle {
                id:             stepper
                readonly property bool  _light: QGroundControl.globalPalette.globalTheme === QGCPalette.Light
                readonly property color _hover: _light ? "#EBEBEB" : "#404040"
                implicitWidth:  stepRow.implicitWidth + 8
                implicitHeight: ScreenTools.defaultFontPixelHeight * 1.6
                radius:         8
                color:          _light ? "#FFFFFF" : "#202020"
                border.color:   _light ? "#E0E0E0" : "#606060"
                border.width:   1

                RowLayout {
                    id:                 stepRow
                    anchors.centerIn:   parent
                    spacing:            0

                    Rectangle {
                        Layout.preferredWidth:  stepper.implicitHeight - 8
                        Layout.preferredHeight: stepper.implicitHeight - 8
                        radius:                 6
                        color:                  minusMouse.containsMouse ? stepper._hover : "transparent"
                        QGCLabel { anchors.centerIn: parent; text: "-" }
                        MouseArea {
                            id:             minusMouse
                            anchors.fill:   parent
                            hoverEnabled:   true
                            cursorShape:    Qt.PointingHandCursor
                            onClicked: {
                                if (_appFontPointSize.value > _appFontPointSize.min) {
                                    _appFontPointSize.value = _appFontPointSize.value - 1
                                }
                            }
                        }
                    }

                    QGCLabel {
                        id:                         baseFontEdit
                        Layout.preferredWidth:      ScreenTools.defaultFontPixelWidth * 7
                        horizontalAlignment:        Text.AlignHCenter
                        text:                       (QGroundControl.settingsManager.appSettings.appFontPointSize.value / ScreenTools.platformFontPointSize * 100).toFixed(0) + "%"
                    }

                    Rectangle {
                        Layout.preferredWidth:  stepper.implicitHeight - 8
                        Layout.preferredHeight: stepper.implicitHeight - 8
                        radius:                 6
                        color:                  plusMouse.containsMouse ? stepper._hover : "transparent"
                        QGCLabel { anchors.centerIn: parent; text: "+" }
                        MouseArea {
                            id:             plusMouse
                            anchors.fill:   parent
                            hoverEnabled:   true
                            cursorShape:    Qt.PointingHandCursor
                            onClicked: {
                                if (_appFontPointSize.value < _appFontPointSize.max) {
                                    _appFontPointSize.value = _appFontPointSize.value + 1
                                }
                            }
                        }
                    }
                }
            }
        }


    }

    AppCard {
        Layout.fillWidth:   true
        Layout.preferredWidth: 1
        heading:            qsTr("Units")
        visible:            QGroundControl.settingsManager.unitsSettings.visible

        OptionRow {
            label:  QGroundControl.settingsManager.unitsSettings.horizontalDistanceUnits.shortDescription
            fact:   QGroundControl.settingsManager.unitsSettings.horizontalDistanceUnits
        }
        OptionRow {
            label:  QGroundControl.settingsManager.unitsSettings.verticalDistanceUnits.shortDescription
            fact:   QGroundControl.settingsManager.unitsSettings.verticalDistanceUnits
        }
        LabelledFactComboBox {
            label:      QGroundControl.settingsManager.unitsSettings.areaUnits.shortDescription
            Layout.minimumHeight: page._rowH; Layout.preferredHeight: page._rowH
            fact:       QGroundControl.settingsManager.unitsSettings.areaUnits
            indexModel: false
        }
        LabelledFactComboBox {
            label:      QGroundControl.settingsManager.unitsSettings.speedUnits.shortDescription
            Layout.minimumHeight: page._rowH; Layout.preferredHeight: page._rowH
            fact:       QGroundControl.settingsManager.unitsSettings.speedUnits
            indexModel: false
        }
        OptionRow {
            label:  QGroundControl.settingsManager.unitsSettings.temperatureUnits.shortDescription
            fact:   QGroundControl.settingsManager.unitsSettings.temperatureUnits
        }
    }

    AppCard {
        Layout.fillWidth:       true
        Layout.preferredWidth:  1
        Layout.columnSpan:      cardGrid.columns
        heading:                qsTr("Storage")
        visible:                _appSavePath.visible && !ScreenTools.isMobile

        RowLayout {
            Layout.minimumHeight:   page._rowH
            Layout.fillWidth:   true
            spacing:            ScreenTools.defaultFontPixelWidth * 2
            visible:            _appSavePath.visible && !ScreenTools.isMobile

            ColumnLayout {
                Layout.fillWidth:   true
                spacing:            0

                QGCLabel { text: qsTr("Application Load/Save Path") }
                QGCLabel {
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    text:               _appSavePath.rawValue === "" ? qsTr("<default location>") : _appSavePath.value
                    elide:              Text.ElideMiddle
                }
            }

            QGCButton {
                text:       qsTr("Browse")
                onClicked:  savePathBrowseDialog.openForLoad()
                QGCFileDialog {
                    id:                 savePathBrowseDialog
                    title:              qsTr("Choose the location to save/load files")
                    folder:             _appSavePath.rawValue
                    selectFolder:       true
                    onAcceptedForLoad:  (file) => _appSavePath.rawValue = file
                }
            }
        }

    }

    // AppCard {
    //     Layout.fillWidth:       true
    //     Layout.preferredWidth:  1
    //     Layout.columnSpan:      cardGrid.columns
    //     heading:                qsTr("Brand Image")

    //     RowLayout {
    //         Layout.fillWidth:   true
    //         spacing:            ScreenTools.defaultFontPixelWidth * 2
    //         visible:            _userBrandImageIndoor.visible

    //         ColumnLayout {
    //             Layout.fillWidth:   true
    //             spacing:            0

    //             QGCLabel {
    //                 Layout.fillWidth:   true
    //                 text:               qsTr("Indoor Image")
    //             }
    //             QGCLabel {
    //                 Layout.fillWidth:   true
    //                 font.pointSize:     ScreenTools.smallFontPointSize
    //                 text:               _userBrandImageIndoor.valueString.replace("file:///", "")
    //                 elide:              Text.ElideMiddle
    //                 visible:            _userBrandImageIndoor.valueString.length > 0
    //             }
    //         }

    //         QGCButton {
    //             text:       qsTr("Browse")
    //             onClicked:  userBrandImageIndoorBrowseDialog.openForLoad()

    //             QGCFileDialog {
    //                 id:                 userBrandImageIndoorBrowseDialog
    //                 title:              qsTr("Choose custom brand image file")
    //                 folder:             _userBrandImageIndoor.rawValue.replace("file:///", "")
    //                 selectFolder:       false
    //                 onAcceptedForLoad:  (file) => _userBrandImageIndoor.rawValue = "file:///" + file
    //             }
    //         }
    //     }

    //     RowLayout {
    //         Layout.fillWidth:   true
    //         spacing:            ScreenTools.defaultFontPixelWidth * 2
    //         visible:            _userBrandImageOutdoor.visible

    //         ColumnLayout {
    //             Layout.fillWidth:   true
    //             spacing:            0

    //             QGCLabel {
    //                 Layout.fillWidth:   true
    //                 text:               qsTr("Outdoor Image")
    //             }
    //             QGCLabel {
    //                 Layout.fillWidth:   true
    //                 font.pointSize:     ScreenTools.smallFontPointSize
    //                 text:               _userBrandImageOutdoor.valueString.replace("file:///", "")
    //                 elide:              Text.ElideMiddle
    //                 visible:            _userBrandImageOutdoor.valueString.length > 0
    //             }
    //         }

    //         QGCButton {
    //             text:       qsTr("Browse")
    //             onClicked:  userBrandImageOutdoorBrowseDialog.openForLoad()

    //             QGCFileDialog {
    //                 id:                 userBrandImageOutdoorBrowseDialog
    //                 title:              qsTr("Choose custom brand image file")
    //                 folder:             _userBrandImageOutdoor.rawValue.replace("file:///", "")
    //                 selectFolder:       false
    //                 onAcceptedForLoad:  (file) => _userBrandImageOutdoor.rawValue = "file:///" + file
    //             }
    //         }
    //     }

    //     LabelledButton {
    //         label:      qsTr("Reset Images")
    //         buttonText: qsTr("Reset")
    //         onClicked:  {
    //             _userBrandImageIndoor.rawValue = ""
    //             _userBrandImageOutdoor.rawValue = ""
    //         }
    //     }

    // }

    }
}