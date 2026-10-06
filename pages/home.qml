import QtQuick
import Rift 1.0
import ".."

FocusScope {
    id: root
    focus: true

    Style { id: ui }
    Prefs { id: prefs }

    property int initialPlatformIndex: 0
    readonly property var currentPlatform: Rift.platforms.count > 0 ? Rift.platforms.get(showcase.currentIndex) : null

    onInitialPlatformIndexChanged: showcase.setIndex(initialPlatformIndex)
    Component.onCompleted: showcase.setIndex(initialPlatformIndex)

    function asset(folder, name, ext) {
        return name ? Rift.assetsPath + "/" + folder + "/" + name + ext : ""
    }

    function openPlatform(index) {
        var p = Rift.platforms.get(index)
        if (p)
            Rift.navigation.push("games", { platform: p, platformIndex: index })
    }

    function metaLine(p) {
        if (!p)
            return ""
        if (p.isVirtual)
            return ui.t("collection")
        return [p.manufacturer, p.releaseYear > 0 ? p.releaseYear : ""].filter(Boolean).join("  ·  ")
    }

    Connections {
        target: Rift.platforms
        function onCountChanged() { showcase.setIndex(root.initialPlatformIndex) }
    }

    Connections {
        target: showcase
        function onCurrentIndexChanged() { Rift.platforms.currentIndex = showcase.currentIndex }
    }

    Connections {
        target: Rift.input
        enabled: root.activeFocus
        function onNavigationLeft() { showcase.move(-1) }
        function onNavigationRight() { showcase.move(1) }
        function onAccept() { root.openPlatform(showcase.currentIndex) }
        function onSearchToggle() { showcase.spin() }
    }

    Keys.onLeftPressed: showcase.move(-1)
    Keys.onRightPressed: showcase.move(1)
    Keys.onReturnPressed: root.openPlatform(showcase.currentIndex)
    Keys.onEnterPressed: root.openPlatform(showcase.currentIndex)
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_I) {
            showcase.spin()
            event.accepted = true
        }
    }

    Showcase {
        id: showcase
        anchors.fill: parent
        model: Rift.platforms
        reflections: prefs.reflections
        shadows: prefs.shadows
        idleMotion: prefs.idleMotion
        coverInfo: function(p) {
            return {
                image: root.asset("backgrounds", p.name, ".jpg"),
                logo: root.asset("logos-white", p.name, ".svg"),
                title: p.displayName,
                accent: ui.caseColor(p.name),
                favorite: false
            }
        }
        onActivated: function(index) { root.openPlatform(index) }
    }

    Column {
        x: 48
        y: 34
        width: root.width * 0.6
        spacing: 8

        Text {
            text: "VITRINA  ·  " + ui.t("systems").toUpperCase()
            font.family: ui.body
            font.pixelSize: 13
            font.weight: Font.Bold
            font.letterSpacing: 4
            color: ui.warm
        }

        Text {
            width: parent.width
            text: root.currentPlatform?.displayName ?? ""
            elide: Text.ElideRight
            font.family: ui.display
            font.pixelSize: 44
            font.weight: Font.Medium
            color: ui.text
        }

        Text {
            text: root.metaLine(root.currentPlatform)
            font.family: ui.body
            font.pixelSize: 17
            font.weight: Font.Medium
            color: ui.muted
        }
    }

    Column {
        anchors.right: parent.right
        anchors.rightMargin: 48
        y: 92
        spacing: 0

        Text {
            anchors.right: parent.right
            text: root.currentPlatform?.gameCount ?? 0
            font.family: ui.display
            font.pixelSize: 54
            font.weight: Font.Light
            color: ui.text
        }

        Text {
            anchors.right: parent.right
            text: ui.t("games").toUpperCase()
            font.family: ui.body
            font.pixelSize: 12
            font.weight: Font.Bold
            font.letterSpacing: 4
            color: ui.muted
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 82
        width: Math.min(parent.width * 0.6, 760)
        horizontalAlignment: Text.AlignHCenter
        text: root.currentPlatform?.description ?? ""
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        font.family: ui.body
        font.pixelSize: 15
        color: ui.muted
    }

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 48
        anchors.bottomMargin: 32
        text: String(showcase.count > 0 ? showcase.currentIndex + 1 : 0).padStart(2, "0") + "  /  " + String(showcase.count).padStart(2, "0")
        font.family: ui.display
        font.pixelSize: 16
        font.weight: Font.Light
        font.letterSpacing: 2
        color: ui.muted
    }

    HintBar {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 48
        anchors.bottomMargin: 30
        hints: [["A", ui.t("open")], ["X", ui.t("random")]]
    }
}
