import QtQuick

QtObject {
    readonly property color void_: "#07080c"
    readonly property color haze: "#141824"
    readonly property color glass: "#cc0d1018"
    readonly property color line: "#2a3142"
    readonly property color text: "#f2f0ea"
    readonly property color muted: "#8a93a8"
    readonly property color warm: "#ffb35c"
    readonly property color cool: "#6fb6ff"
    readonly property color heart: "#ff5a6e"

    readonly property var caseColors: ["#2b3a67", "#5a2b67", "#67402b", "#2b674f", "#672b3a",
                                       "#2b5a67", "#675f2b", "#3b2b67", "#2b6730", "#4a4f5a"]

    property FontLoader displayLoader: FontLoader { source: "fonts/Unbounded.ttf" }
    property FontLoader bodyLoader: FontLoader { source: "fonts/Manrope.ttf" }
    readonly property string display: displayLoader.status === FontLoader.Ready ? displayLoader.name : "Helvetica"
    readonly property string body: bodyLoader.status === FontLoader.Ready ? bodyLoader.name : "Helvetica"

    readonly property var strings: ({
        "systems": ["Systems", "Sistemas"],
        "games": ["games", "juegos"],
        "open": ["Open", "Abrir"],
        "play": ["Play", "Jugar"],
        "random": ["Random", "Aleatorio"],
        "favorite": ["Favorite", "Favorito"],
        "system": ["System", "Sistema"],
        "back": ["Back", "Volver"],
        "noGames": ["No games here yet", "Todavía no hay juegos"],
        "starting": ["Starting", "Iniciando"],
        "neverPlayed": ["Never played", "Sin jugar"],
        "lastPlayed": ["Last played", "Jugado el"],
        "plays": ["plays", "partidas"],
        "collection": ["Collection", "Colección"]
    })

    function t(key) {
        var entry = strings[key]
        if (!entry)
            return key
        return Rift.settings.language === "es" ? entry[1] : entry[0]
    }

    function caseColor(key) {
        var h = 0
        var s = String(key || "")
        for (var i = 0; i < s.length; i++)
            h = (h * 31 + s.charCodeAt(i)) % 9973
        return caseColors[h % caseColors.length]
    }
}
