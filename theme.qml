import QtQuick
import Rift 1.0

FocusScope {
    id: root
    focus: true

    Style { id: ui }

    property bool footerVisible: false
    property color menuBackgroundColor: "#0d1018"
    property color menuTextColor: ui.text
    property color menuAccentColor: ui.warm
    property color menuSecondaryColor: "#171b26"
    property color menuBorderColor: ui.line
    property real menuBackgroundOpacity: 0.96
    property string menuFontFamily: ui.body

    property bool reflections: Rift.themeSettingBool("reflections", true)
    property bool shadows: Rift.themeSettingBool("shadows", true)
    property bool idleMotion: Rift.themeSettingBool("idleMotion", true)
    readonly property real canvasScale: height > 0 ? height / 720 : 1

    Connections {
        target: Rift
        function onThemeSettingChanged(key, value) {
            if (key === "reflections") root.reflections = value
            else if (key === "shadows") root.shadows = value
            else if (key === "idleMotion") root.idleMotion = value
        }
    }

    Connections {
        target: Rift.input
        enabled: Rift.navigation.currentPage === "games"
        function onPageUp() { root.switchPlatform(-1) }
        function onPageDown() { root.switchPlatform(1) }
    }

    Keys.onPressed: function(event) {
        if (Rift.navigation.currentPage !== "games" || event.isAutoRepeat)
            return
        if (event.key === Qt.Key_Q || event.key === Qt.Key_PageUp) {
            root.switchPlatform(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_E || event.key === Qt.Key_PageDown) {
            root.switchPlatform(1)
            event.accepted = true
        }
    }

    function switchPlatform(step) {
        var count = Rift.platforms.count
        if (count < 2)
            return
        var index = ((Rift.navigation.params.platformIndex ?? 0) + step + count) % count
        Rift.navigation.updateBackPlatformIndex(index)
        Rift.navigation.replace("games", { platform: Rift.platforms.get(index), platformIndex: index })
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#10141f" }
            GradientStop { position: 0.55; color: "#0a0c13" }
            GradientStop { position: 1.0; color: "#050609" }
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: -parent.height * 0.55
        width: parent.width * 0.9
        height: parent.height * 1.3
        radius: width / 2
        opacity: 0.35
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.55; color: "#2a2433" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Item {
        id: canvas
        width: root.width / root.canvasScale
        height: 720
        scale: root.canvasScale
        transformOrigin: Item.TopLeft

        RiftRouter {
            anchors.fill: parent
            focus: true
            transition: "fade"
        }

        Text {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 30
            anchors.rightMargin: 40
            font.family: ui.display
            font.pixelSize: 20
            font.weight: Font.Light
            font.letterSpacing: 2
            color: ui.muted
            text: Qt.formatTime(clock.now, "hh:mm")
        }
    }

    QtObject {
        id: clock
        property date now: new Date()
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: clock.now = new Date()
    }
}
