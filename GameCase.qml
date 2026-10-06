import QtQuick
import QtQuick3D

Node {
    id: root

    property Texture coverTexture: null
    property color accent: "#2b3a67"
    property bool favorite: false
    property bool mirrored: false
    property real caseWidth: 130
    property real caseHeight: 180
    property real caseDepth: 24

    PrincipledMaterial {
        id: shellMaterial
        baseColor: "#101218"
        roughness: 0.32
        metalness: 0.05
        clearcoatAmount: 0.6
        clearcoatRoughnessAmount: 0.15
        cullMode: root.mirrored ? Material.NoCulling : Material.BackFaceCulling
    }

    PrincipledMaterial {
        id: coverMaterial
        roughness: 0.22
        metalness: 0.0
        clearcoatAmount: 0.8
        clearcoatRoughnessAmount: 0.08
        cullMode: root.mirrored ? Material.NoCulling : Material.BackFaceCulling
        baseColorMap: root.coverTexture
    }

    PrincipledMaterial {
        id: spineMaterial
        baseColor: root.accent
        roughness: 0.4
        cullMode: root.mirrored ? Material.NoCulling : Material.BackFaceCulling
    }

    PrincipledMaterial {
        id: heartMaterial
        baseColor: "#ff5a6e"
        emissiveFactor: Qt.vector3d(0.9, 0.25, 0.3)
        roughness: 0.3
        cullMode: root.mirrored ? Material.NoCulling : Material.BackFaceCulling
    }

    Model {
        source: "#Cube"
        scale: Qt.vector3d(root.caseWidth / 100, root.caseHeight / 100, root.caseDepth / 100)
        materials: [shellMaterial]
        castsShadows: !root.mirrored
        receivesShadows: !root.mirrored
    }

    Model {
        source: "#Rectangle"
        position: Qt.vector3d(0, 0, root.caseDepth / 2 + 0.4)
        scale: Qt.vector3d(root.caseWidth * 0.94 / 100, root.caseHeight * 0.95 / 100, 1)
        materials: [coverMaterial]
        receivesShadows: !root.mirrored
    }

    Model {
        source: "#Rectangle"
        position: Qt.vector3d(-root.caseWidth / 2 - 0.4, 0, 0)
        eulerRotation.y: -90
        scale: Qt.vector3d(root.caseDepth * 0.8 / 100, root.caseHeight * 0.95 / 100, 1)
        materials: [spineMaterial]
    }

    Model {
        visible: root.favorite
        source: "#Sphere"
        position: Qt.vector3d(root.caseWidth / 2 - 14, root.caseHeight / 2 - 14, root.caseDepth / 2 + 4)
        scale: Qt.vector3d(0.11, 0.11, 0.05)
        materials: [heartMaterial]
    }
}
