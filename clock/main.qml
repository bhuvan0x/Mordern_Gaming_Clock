import QtQuick 2.15
import QtQuick.Window 2.15
import "config.js" as Config

/*
 * XFCE host for Prayag2's KDE Modern Clock presentation.
 * Original typography and output are retained; the host window is
 * frameless, transparent and initially centered on the X11 screen.
 */
Window {
    id: root
    title: "Modern Gaming Clock"
    visible: true
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.Tool

    property date currentDate: new Date()

    width: clockColumn.implicitWidth + 2
    height: clockColumn.implicitHeight + 2
    x: Math.round((Screen.width - width) / 2) + Config.center_offset_x
    y: Math.round((Screen.height - height) / 2) + Config.center_offset_y

    FontLoader {
        id: fontAnurati
        source: Qt.resolvedUrl("fonts/Anurati.otf")
    }
    FontLoader {
        id: fontPoppins
        source: Qt.resolvedUrl("fonts/Poppins.ttf")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.currentDate = new Date()
    }

    Column {
        id: clockColumn
        anchors.centerIn: parent
        spacing: 5

        Text {
            id: displayDay
            visible: Config.show_day
            text: Qt.formatDate(root.currentDate, "dddd").toUpperCase()
            font.family: fontAnurati.name
            font.pixelSize: Config.day_font_size
            font.letterSpacing: Config.day_letter_spacing
            color: Config.day_font_color
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: displayDate
            visible: Config.show_date
            text: Qt.formatDate(root.currentDate, Config.date_format).toUpperCase()
            font.family: fontPoppins.name
            font.pixelSize: Config.date_font_size
            font.letterSpacing: Config.date_letter_spacing
            color: Config.date_font_color
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: displayTime
            visible: Config.show_time
            text: Config.time_character + " " +
                  Qt.formatTime(root.currentDate, Config.use_24_hour_format ? "hh:mm" : "hh:mm AP") +
                  " " + Config.time_character
            font.family: fontPoppins.name
            font.pixelSize: Config.time_font_size
            font.letterSpacing: Config.time_letter_spacing
            color: Config.time_font_color
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // Drag the clock; it starts centered and can be repositioned manually.
    MouseArea {
        anchors.fill: parent
        z: 10
        property point pressPosition
        onPressed: function(mouse) {
            pressPosition = Qt.point(mouse.x, mouse.y)
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                root.x += mouse.x - pressPosition.x
                root.y += mouse.y - pressPosition.y
            }
        }
    }
}
