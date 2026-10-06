import QtQuick
import Rift 1.0
import ".."

FocusScope {
    id: root
    focus: true

    Style { id: ui }
    Prefs { id: prefs }

    property var platform: Rift.platforms.get(0)
    property int initialGameIndex: 0
    property int revision: 0
    readonly property var gamesModel: Rift.getGamesModelForPlatform(platform?.id ?? -1)
    readonly property var game: {
        root.revision
        return gamesModel && gamesModel.count > 0 ? gamesModel.get(showcase.currentIndex) : null
    }

    onInitialGameIndexChanged: showcase.setIndex(initialGameIndex)
    Component.onCompleted: showcase.setIndex(initialGameIndex)
    Component.onDestruction: Rift.contextGame = {}

    onGameChanged: {
        if (game && game.id) {
            Rift.selectedGameId = game.id
            Rift.setContextGameById(game.id)
        }
    }

    function yearOf(g) {
        var y = g && g.releaseDate ? parseInt(String(g.releaseDate).substring(0, 4), 10) : 0
        return y > 1970 ? y : 0
    }

    function playedLine(g) {
        if (!g)
            return ""
        var d = g.lastPlayed ? new Date(g.lastPlayed) : null
        var when = d && !isNaN(d.getTime()) && d.getFullYear() > 1970
            ? ui.t("lastPlayed") + " " + Qt.formatDate(d, "dd/MM/yyyy")
            : ui.t("neverPlayed")
        return g.playCount > 0 ? when + "  ·  " + g.playCount + " " + ui.t("plays") : when
    }

    function launch() {
        if (!game || showcase.launching)
            return
        showcase.launching = true
        flash.restart()
        launchTimer.start()
    }

    function toggleFavorite() {
        if (!game)
            return
        Rift.setGameFavorite(game.id, !game.favorite)
        root.revision++
        showcase.revision++
    }

    Connections {
        target: root.gamesModel
        function onCountChanged() { showcase.setIndex(root.initialGameIndex) }
    }

    Connections {
        target: Rift
        function onGameArtworkUpdated(gameId) {
            root.revision++
            showcase.revision++
        }
    }

    Connections {
        target: Rift.input
        enabled: root.activeFocus
        function onNavigationLeft() { showcase.move(-1) }
        function onNavigationRight() { showcase.move(1) }
        function onAccept() { root.launch() }
        function onFavoriteToggle() { root.toggleFavorite() }
        function onSearchToggle() { showcase.spin() }
    }

    Keys.onLeftPressed: showcase.move(-1)
    Keys.onRightPressed: showcase.move(1)
    Keys.onReturnPressed: root.launch()
    Keys.onEnterPressed: root.launch()
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_F) {
            root.toggleFavorite()
            event.accepted = true
        } else if (event.key === Qt.Key_I) {
            showcase.spin()
            event.accepted = true
        }
    }

    Timer {
        id: launchTimer
        interval: 800
        onTriggered: {
            if (root.game)
                Rift.launchGame(root.game.id)
            resetTimer.start()
        }
    }

    Timer {
        id: resetTimer
        interval: 1200
        onTriggered: showcase.launching = false
    }

    Showcase {
        id: showcase
        anchors.fill: parent
        model: root.gamesModel
        reflections: prefs.reflections
        shadows: prefs.shadows
        idleMotion: prefs.idleMotion
        coverInfo: function(g) {
            return {
                image: Rift.imageSource(g.boxart || g.screenshot || ""),
                logo: "",
                title: g.name,
                accent: ui.caseColor(g.name),
                favorite: g.favorite
            }
        }
        onActivated: root.launch()
    }

    Text {
        anchors.centerIn: parent
        visible: showcase.count === 0
        text: ui.t("noGames")
        font.family: ui.display
        font.pixelSize: 30
        font.weight: Font.Light
        color: ui.muted
    }

    Column {
        x: 48
        y: 34
        width: root.width * 0.62
        spacing: 8

        Text {
            text: (root.platform?.displayName ?? "").toUpperCase()
            font.family: ui.body
            font.pixelSize: 13
            font.weight: Font.Bold
            font.letterSpacing: 4
            color: ui.warm
        }

        Row {
            spacing: 14
            width: parent.width

            Text {
                width: Math.min(implicitWidth, parent.width - 40)
                text: root.game?.name ?? ""
                elide: Text.ElideRight
                font.family: ui.display
                font.pixelSize: 40
                font.weight: Font.Medium
                color: ui.text
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.game?.favorite ?? false
                text: "♥"
                font.pixelSize: 30
                color: ui.heart
            }
        }

        Text {
            text: root.game ? [root.yearOf(root.game) || "", root.game.genre, root.game.developer].filter(Boolean).join("  ·  ") : ""
            font.family: ui.body
            font.pixelSize: 17
            font.weight: Font.Medium
            color: ui.muted
        }

        Text {
            text: root.playedLine(root.game)
            font.family: ui.body
            font.pixelSize: 14
            color: ui.muted
            opacity: 0.8
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 48
        y: 104
        spacing: 6
        visible: (root.game?.rating ?? 0) > 0

        Repeater {
            model: 5

            Rectangle {
                required property int index
                width: 26
                height: 6
                radius: 3
                color: index < Math.round((root.game?.rating ?? 0) * 5) ? ui.warm : ui.line
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 82
        width: Math.min(parent.width * 0.62, 780)
        horizontalAlignment: Text.AlignHCenter
        text: root.game?.description ?? ""
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
        text: String(showcase.count > 0 ? showcase.currentIndex + 1 : 0).padStart(3, "0") + "  /  " + String(showcase.count).padStart(3, "0")
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
        hints: [["A", ui.t("play")], ["Y", ui.t("favorite")], ["X", ui.t("random")], ["L/R", ui.t("system")], ["B", ui.t("back")]]
    }

    Rectangle {
        id: flashRect
        anchors.fill: parent
        color: "#fff6ea"
        opacity: 0

        Text {
            anchors.centerIn: parent
            text: ui.t("starting").toUpperCase()
            font.family: ui.display
            font.pixelSize: 22
            font.weight: Font.Light
            font.letterSpacing: 8
            color: "#1a1d26"
        }

        SequentialAnimation {
            id: flash
            PauseAnimation { duration: 520 }
            NumberAnimation { target: flashRect; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InQuad }
            PauseAnimation { duration: 900 }
            NumberAnimation { target: flashRect; property: "opacity"; to: 0; duration: 500; easing.type: Easing.OutQuad }
        }
    }
}
