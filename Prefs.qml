import QtQuick

QtObject {
    id: prefs

    property bool reflections: Rift.themeSettingBool("reflections", true)
    property bool shadows: Rift.themeSettingBool("shadows", true)
    property bool idleMotion: Rift.themeSettingBool("idleMotion", true)

    property Connections watcher: Connections {
        target: Rift
        function onThemeSettingChanged(key, value) {
            if (key === "reflections") prefs.reflections = value
            else if (key === "shadows") prefs.shadows = value
            else if (key === "idleMotion") prefs.idleMotion = value
        }
    }
}
