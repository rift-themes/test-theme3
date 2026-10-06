import QtQuick
import QtQuick3D

Item {
    id: showcase

    property var model: null
    property var coverInfo: null
    property int revision: 0
    property bool reflections: true
    property bool shadows: true
    property bool idleMotion: true
    property bool launching: false
    property real caseWidth: 130
    property real caseHeight: 180

    readonly property int count: model ? model.count : 0
    readonly property int sideSlots: 5
    property int pos: 0
    readonly property int currentIndex: count > 0 ? ((pos % count) + count) % count : 0
    property real scroll: pos
    property bool jumping: false
    property real phase: 0
    readonly property real sway: idleMotion ? Math.sin(phase) : 0

    signal activated(int index)

    Behavior on scroll {
        enabled: !showcase.jumping
        SpringAnimation { spring: 3.2; damping: 0.42; mass: 0.9; epsilon: 0.002 }
    }

    NumberAnimation on phase {
        from: 0
        to: Math.PI * 2
        duration: 14000
        loops: Animation.Infinite
        running: showcase.idleMotion && showcase.visible
    }

    function move(step) {
        if (count > 0 && !launching)
            pos += step
    }

    function setIndex(index) {
        if (count <= 0)
            return
        jumping = true
        pos = Math.max(0, Math.min(index, count - 1))
        jumping = false
    }

    function spin(onDone) {
        if (count < 2 || spinTimer.running || launching)
            return
        spinTimer.target = pos + count + Math.floor(Math.random() * count)
        spinTimer.done = onDone || null
        spinTimer.interval = 45
        spinTimer.start()
    }

    Timer {
        id: spinTimer
        property int target: 0
        property var done: null
        repeat: true
        onTriggered: {
            showcase.pos += 1
            var left = target - showcase.pos
            if (left <= 0) {
                stop()
                if (done)
                    done()
                return
            }
            interval = 45 + Math.pow(Math.max(0, 1 - left / showcase.count), 3) * 300
        }
    }

    View3D {
        id: view
        anchors.fill: parent

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
            tonemapMode: SceneEnvironment.TonemapModeFilmic
            fog: Fog {
                enabled: true
                color: "#07080c"
                depthEnabled: true
                depthNear: 560
                depthFar: 1500
            }
        }

        PerspectiveCamera {
            position: Qt.vector3d(showcase.sway * 26, 175 + showcase.sway * 6, 640)
            eulerRotation.x: -5.5
            eulerRotation.y: showcase.sway * 2.2
            fieldOfView: 38
            clipFar: 4000
        }

        DirectionalLight {
            eulerRotation.x: -42
            eulerRotation.y: -28
            color: "#fff1de"
            brightness: 1.15
            castsShadow: showcase.shadows
            shadowFactor: 55
            shadowMapQuality: Light.ShadowMapQualityHigh
            shadowMapFar: 2400
        }

        DirectionalLight {
            eulerRotation.x: -25
            eulerRotation.y: 165
            color: "#7fb8ff"
            brightness: 0.75
        }

        DirectionalLight {
            eulerRotation.x: -8
            eulerRotation.y: 10
            color: "#c8ccd8"
            brightness: 0.28
        }

        Model {
            source: "#Rectangle"
            eulerRotation.x: -90
            scale: Qt.vector3d(40, 24, 1)
            receivesShadows: true
            materials: PrincipledMaterial {
                baseColor: "#0b0d13"
                roughness: 0.3
                metalness: 0.0
                alphaMode: showcase.reflections ? PrincipledMaterial.Blend : PrincipledMaterial.Opaque
                opacity: showcase.reflections ? 0.84 : 1.0
            }
        }

        Repeater3D {
            model: showcase.count > 0 ? showcase.sideSlots * 2 + 1 : 0

            delegate: Node {
                id: slot

                required property int index
                readonly property int offset: index - showcase.sideSlots
                readonly property int base: Math.round(showcase.scroll)
                readonly property int absolute: base + offset
                readonly property int dataIndex: ((absolute % showcase.count) + showcase.count) % showcase.count
                readonly property real d: absolute - showcase.scroll
                readonly property real ad: Math.abs(d)
                readonly property real cd: Math.max(-1, Math.min(1, d))
                readonly property bool isCurrent: absolute === showcase.pos
                readonly property bool flying: isCurrent && showcase.launching
                readonly property var cardData: {
                    showcase.revision
                    return showcase.count > 0 ? showcase.model.get(dataIndex) : null
                }
                readonly property var info: showcase.coverInfo && cardData ? showcase.coverInfo(cardData) : ({})
                readonly property bool inWindow: showcase.count > showcase.sideSlots * 2
                    || (absolute >= showcase.pos - Math.floor(showcase.count / 2)
                        && absolute < showcase.pos - Math.floor(showcase.count / 2) + showcase.count)

                visible: inWindow && ad < showcase.sideSlots + 0.5
                x: ad <= 1 ? d * 175 : (d > 0 ? 1 : -1) * (175 + (ad - 1) * 70)
                y: showcase.caseHeight / 2 + (flying ? 30 : 0)
                z: -Math.min(ad, 1) * 150 - Math.max(0, ad - 1) * 10 + (flying ? 330 : 0)
                eulerRotation.y: -cd * 62 + (isCurrent ? showcase.sway * 7 : 0) + (flying ? 360 : 0)

                Behavior on z { enabled: showcase.launching; NumberAnimation { duration: 700; easing.type: Easing.InOutCubic } }
                Behavior on y { enabled: showcase.launching; NumberAnimation { duration: 700; easing.type: Easing.InOutCubic } }
                Behavior on eulerRotation.y { enabled: showcase.launching; NumberAnimation { duration: 700; easing.type: Easing.InOutCubic } }

                Texture {
                    id: coverTexture
                    generateMipmaps: true
                    mipFilter: Texture.Linear
                    sourceItem: CoverArt {
                        imageSource: slot.info.image || ""
                        logoSource: slot.info.logo || ""
                        title: slot.info.title || ""
                        accent: slot.info.accent || "#2b3a67"
                    }
                }

                GameCase {
                    coverTexture: coverTexture
                    accent: slot.info.accent || "#2b3a67"
                    favorite: slot.info.favorite || false
                    caseWidth: showcase.caseWidth
                    caseHeight: showcase.caseHeight
                }

                GameCase {
                    visible: showcase.reflections && !slot.flying
                    mirrored: true
                    y: -showcase.caseHeight - 1
                    scale.y: -1
                    coverTexture: coverTexture
                    accent: slot.info.accent || "#2b3a67"
                    caseWidth: showcase.caseWidth
                    caseHeight: showcase.caseHeight
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            if (mouse.x < width * 0.38)
                showcase.move(-1)
            else if (mouse.x > width * 0.62)
                showcase.move(1)
            else
                showcase.activated(showcase.currentIndex)
        }
        onWheel: function(wheel) {
            showcase.move((wheel.angleDelta.y + wheel.angleDelta.x) < 0 ? 1 : -1)
        }
    }
}
