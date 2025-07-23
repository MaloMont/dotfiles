import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "root:/"


PanelWindow {
    id: calendarOverlay

    visible: false

    anchors.top: true
    anchors.right: true

    implicitWidth: 400
    implicitHeight: 320

    color: "transparent"

    Rectangle {
        color: Theme.base
        radius: Theme.radius

        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 1

            // Month/Year header with navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: ""
                    color: previousBtnArea.containsMouse ? Theme.textFocused : Theme.text

                    MouseArea {
                        id: previousBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
            
                        onClicked: {
                            let newDate = new Date(calendar.year, calendar.month - 1, 1);
                            calendar.year = newDate.getFullYear();
                            calendar.month = newDate.getMonth();
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: calendar.title
                    color: Theme.text
                    font.pointSize: Theme.fontSize
                    font.bold: true
                }

                Text {
                    text: ""
                    color: nextBtnArea.containsMouse ? Theme.textFocused : Theme.text

                    MouseArea {
                        id: nextBtnArea

                        anchors.fill: parent
                        hoverEnabled: true
            
                        onClicked: {
                            let newDate = new Date(calendar.year, calendar.month + 1, 1);
                            calendar.year = newDate.getFullYear();
                            calendar.month = newDate.getMonth();
                        }
                    }
                }
            }

            DayOfWeekRow {
                Layout.fillWidth: true
                spacing: 0
                Layout.leftMargin: 2  // Align with grid
                Layout.rightMargin: 2
                delegate: Text {
                    text: shortName
                    color: Theme.text
                    opacity: 1
                    font.pointSize: Theme.fontSize
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            MonthGrid {
                id: calendar
                Layout.fillWidth: true
                Layout.leftMargin: 2
                Layout.rightMargin: 2
                spacing: 0
                month: Time.date.getMonth()
                year: Time.date.getFullYear()

                delegate: Rectangle {
                    implicitWidth: 10
                    implicitHeight: 32
                    radius: 8
                    color: {
                        if (model.today)
                            return Theme.intensity1;
                        if (mouseArea2.containsMouse)
                            return Theme.dark_base;
                        return "transparent";
                    }

                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        color: model.today
                            ? Theme.dark_base
                            : (mouseArea2.containsMouse
                                ? Theme.textFocused
                                : Theme.text)

                        opacity: model.month === calendar.month ? 1.0 : 0.4
                        font.pointSize: Theme.fontSize
                        font.bold: model.today ? true : false
                    }

                    MouseArea {
                        id: mouseArea2
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }
        }
    }
}