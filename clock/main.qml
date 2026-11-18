import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1
import "wallpaper-theme.js" as WallpaperTheme

Window {
    id: root
    title: "Modern Gaming Clock"
    visible: false
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.Tool

    property date currentDate: new Date()
    property bool restoringPosition: true
    property point dragOrigin
    property real startX: 0
    property real startY: 0

    Settings {
        id: prefs
        category: "ModernGamingClock"
        property bool showDay: true
        property bool showDate: true
        property bool showTime: true
        property string timeZone: "Asia/Kolkata"
        property string localeName: "en-IN"
        property bool use24Hour: true
        property string dateStyle: "dd MMM yyyy"
        property string colorMode: "Wallpaper adaptive"
        property int dayFontSize: 72
        property int dateFontSize: 19
        property int timeFontSize: 19
        property bool positionSaved: false
        property real windowX: -1
        property real windowY: -1
    }

    function formattedDay() {
        try {
            return new Intl.DateTimeFormat(prefs.localeName, {
                timeZone: prefs.timeZone, weekday: "long"
            }).format(currentDate).toUpperCase()
        } catch (e) {
            return Qt.formatDate(currentDate, "dddd").toUpperCase()
        }
    }

    function formattedDate() {
        var options = { timeZone: prefs.timeZone, year: "numeric" }
        if (prefs.dateStyle === "MMMM d, yyyy") {
            options.month = "long"; options.day = "numeric"
        } else if (prefs.dateStyle === "dd/MM/yyyy") {
            options.month = "2-digit"; options.day = "2-digit"
        } else if (prefs.dateStyle === "yyyy-MM-dd") {
            options.month = "2-digit"; options.day = "2-digit"
        } else {
            options.month = "short"; options.day = "2-digit"
        }
        try {
            var result = new Intl.DateTimeFormat(prefs.localeName, options).format(currentDate)
            if (prefs.dateStyle === "yyyy-MM-dd") {
                var p = new Intl.DateTimeFormat("en-CA", {
                    timeZone: prefs.timeZone, year: "numeric", month: "2-digit", day: "2-digit"
                }).formatToParts(currentDate)
                var parts = {}
                for (var i = 0; i < p.length; ++i) parts[p[i].type] = p[i].value
                return parts.year + "-" + parts.month + "-" + parts.day
            }
            return result.toUpperCase()
        } catch (e) {
            return Qt.formatDate(currentDate, "dd MMM yyyy").toUpperCase()
        }
    }

    function formattedTime() {
        try {
            return new Intl.DateTimeFormat(prefs.localeName, {
                timeZone: prefs.timeZone,
                hour: "2-digit",
                minute: "2-digit",
                hour12: !prefs.use24Hour
            }).format(currentDate)
        } catch (e) {
            return Qt.formatTime(currentDate, prefs.use24Hour ? "hh:mm" : "hh:mm AP")
        }
    }

    function clockColor() {
        if (prefs.colorMode === "White") return "#FFFFFF"
        if (prefs.colorMode === "Dark") return "#111827"
        return WallpaperTheme.textColor
    }

    function persistPosition() {
        prefs.windowX = root.x
        prefs.windowY = root.y
        prefs.positionSaved = true
        prefs.sync()
    }

    width: Math.max(clockColumn.implicitWidth + 24, 170)
    height: clockColumn.implicitHeight + 22

    Component.onCompleted: {
        if (prefs.positionSaved && prefs.windowX >= 0 && prefs.windowY >= 0) {
            root.x = Math.min(prefs.windowX, Math.max(0, Screen.width - width))
            root.y = Math.min(prefs.windowY, Math.max(0, Screen.height - height))
        } else {
            root.x = Math.round((Screen.width - width) / 2)
            root.y = Math.round((Screen.height - height) / 2)
            persistPosition()
        }
        restoringPosition = false
        root.color = Qt.rgba(0, 0, 0, 0)
        root.show()
    }

    onXChanged: if (!restoringPosition) { prefs.windowX = x; prefs.positionSaved = true }
    onYChanged: if (!restoringPosition) { prefs.windowY = y; prefs.positionSaved = true }

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
            visible: prefs.showDay
            text: root.formattedDay()
            font.family: fontAnurati.name
            font.pixelSize: prefs.dayFontSize
            font.letterSpacing: 17
            color: root.clockColor()
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            visible: prefs.showDate
            text: root.formattedDate()
            font.family: fontPoppins.name
            font.pixelSize: prefs.dateFontSize
            font.letterSpacing: 3
            color: root.clockColor()
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            visible: prefs.showTime
            text: "-  " + root.formattedTime() + "  -"
            font.family: fontPoppins.name
            font.pixelSize: prefs.timeFontSize
            font.letterSpacing: 3
            color: root.clockColor()
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 10
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: pressed && mouse.button === Qt.LeftButton ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.dragOrigin = Qt.point(mouse.x, mouse.y)
                root.startX = root.x
                root.startY = root.y
            }
        }
        onPositionChanged: function(mouse) {
            if (pressed && (mouse.buttons & Qt.LeftButton)) {
                root.x = root.startX + mouse.x - root.dragOrigin.x
                root.y = root.startY + mouse.y - root.dragOrigin.y
            }
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) root.persistPosition()
        }
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) settingsWindow.visible = true
        }
    }

    Window {
        id: settingsWindow
        title: "Modern Gaming Clock • Control Centre"
        visible: false
        width: 430
        height: 650
        color: "#111827"
        flags: Qt.Dialog
        modality: Qt.NonModal
        transientParent: root

        ScrollView {
            anchors.fill: parent
            clip: true

            Column {
                width: settingsWindow.width
                padding: 22
                spacing: 14

                Label {
                    text: "CLOCK CONTROL CENTRE"
                    color: "#F8FAFC"
                    font.pixelSize: 20
                    font.bold: true
                }
                Label {
                    text: "Personalize your clock. Changes are saved automatically."
                    color: "#94A3B8"
                    wrapMode: Text.WordWrap
                    width: parent.width - 44
                }

                GroupBox {
                    title: "REGION & TIME"
                    width: parent.width - 44
                    Column {
                        width: parent.width
                        spacing: 8
                        Label { text: "Time zone"; color: "#E2E8F0" }
                        ComboBox {
                            width: parent.width
                            model: [
                                "Asia/Kolkata", "Asia/Tokyo", "Asia/Seoul", "Asia/Shanghai",
                                "Asia/Singapore", "Asia/Dubai", "Asia/Riyadh", "Asia/Jerusalem",
                                "Europe/London", "Europe/Paris", "Europe/Berlin", "Europe/Moscow",
                                "America/New_York", "America/Chicago", "America/Denver",
                                "America/Los_Angeles", "America/Toronto", "America/Sao_Paulo",
                                "Australia/Sydney", "Pacific/Auckland", "UTC"
                            ]
                            currentIndex: Math.max(0, model.indexOf(prefs.timeZone))
                            onActivated: prefs.timeZone = currentText
                        }
                        Label { text: "Language / regional format"; color: "#E2E8F0" }
                        ComboBox {
                            width: parent.width
                            model: ["en-IN", "en-GB", "en-US", "ja-JP", "ru-RU", "fr-FR", "de-DE", "es-ES"]
                            currentIndex: Math.max(0, model.indexOf(prefs.localeName))
                            onActivated: prefs.localeName = currentText
                        }
                        CheckBox {
                            text: "24-hour time"
                            checked: prefs.use24Hour
                            onToggled: prefs.use24Hour = checked
                        }
                        Label { text: "Date format"; color: "#E2E8F0" }
                        ComboBox {
                            width: parent.width
                            model: ["dd MMM yyyy", "MMMM d, yyyy", "dd/MM/yyyy", "yyyy-MM-dd"]
                            currentIndex: Math.max(0, model.indexOf(prefs.dateStyle))
                            onActivated: prefs.dateStyle = currentText
                        }
                    }
                }

                GroupBox {
                    title: "DISPLAY"
                    width: parent.width - 44
                    Column {
                        width: parent.width
                        spacing: 5
                        CheckBox { text: "Show weekday"; checked: prefs.showDay; onToggled: prefs.showDay = checked }
                        CheckBox { text: "Show date"; checked: prefs.showDate; onToggled: prefs.showDate = checked }
                        CheckBox { text: "Show time"; checked: prefs.showTime; onToggled: prefs.showTime = checked }
                        Label { text: "Text appearance"; color: "#E2E8F0" }
                        ComboBox {
                            width: parent.width
                            model: ["Wallpaper adaptive", "White", "Dark"]
                            currentIndex: Math.max(0, model.indexOf(prefs.colorMode))
                            onActivated: prefs.colorMode = currentText
                        }
                        Label { text: "Weekday size: " + prefs.dayFontSize + " px"; color: "#CBD5E1" }
                        Slider { width: parent.width; from: 42; to: 100; stepSize: 2; value: prefs.dayFontSize; onMoved: prefs.dayFontSize = Math.round(value) }
                        Label { text: "Date size: " + prefs.dateFontSize + " px"; color: "#CBD5E1" }
                        Slider { width: parent.width; from: 12; to: 36; stepSize: 1; value: prefs.dateFontSize; onMoved: prefs.dateFontSize = Math.round(value) }
                        Label { text: "Time size: " + prefs.timeFontSize + " px"; color: "#CBD5E1" }
                        Slider { width: parent.width; from: 12; to: 36; stepSize: 1; value: prefs.timeFontSize; onMoved: prefs.timeFontSize = Math.round(value) }
                    }
                }

                GroupBox {
                    title: "POSITION"
                    width: parent.width - 44
                    Column {
                        width: parent.width
                        spacing: 8
                        Label { text: "Drag the clock with the left mouse button. Right-click it to reopen this panel."; color: "#CBD5E1"; wrapMode: Text.WordWrap; width: parent.width }
                        Button {
                            text: "Center clock on screen"
                            onClicked: {
                                root.restoringPosition = true
                                root.x = Math.round((Screen.width - root.width) / 2)
                                root.y = Math.round((Screen.height - root.height) / 2)
                                root.restoringPosition = false
                                root.persistPosition()
                            }
                        }
                    }
                }

                Row {
                    spacing: 10
                    Button { text: "Close"; onClicked: settingsWindow.visible = false }
                    Button {
                        text: "Reset clock settings"
                        onClicked: {
                            prefs.showDay = true; prefs.showDate = true; prefs.showTime = true
                            prefs.timeZone = "Asia/Kolkata"; prefs.localeName = "en-IN"
                            prefs.use24Hour = true; prefs.dateStyle = "dd MMM yyyy"
                            prefs.colorMode = "Wallpaper adaptive"
                            prefs.dayFontSize = 72; prefs.dateFontSize = 19; prefs.timeFontSize = 19
                            prefs.sync()
                        }
                    }
                }
            }
        }
    }
}
