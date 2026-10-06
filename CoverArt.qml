import QtQuick

Rectangle {
    id: root

    property string imageSource: ""
    property string logoSource: ""
    property string title: ""
    property color accent: "#2b3a67"

    width: 512
    height: 704
    color: accent

    Style { id: ui }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(root.accent, 1.35) }
            GradientStop { position: 1.0; color: Qt.darker(root.accent, 1.6) }
        }
    }

    Text {
        anchors.centerIn: parent
        width: parent.width - 80
        visible: art.status !== Image.Ready && logo.status !== Image.Ready
        text: root.title
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 4
        font.family: ui.display
        font.pixelSize: 54
        font.weight: Font.DemiBold
        color: ui.text
    }

    Image {
        id: art
        anchors.fill: parent
        source: root.imageSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: 512
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        visible: art.visible && logo.visible
        gradient: Gradient {
            GradientStop { position: 0.45; color: "#00000000" }
            GradientStop { position: 1.0; color: "#cc000000" }
        }
    }

    Image {
        id: logo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: art.visible ? 60 : (parent.height - height) / 2
        width: parent.width - 96
        height: 200
        source: root.logoSource
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        sourceSize: Qt.size(420, 200)
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 10
        color: "#33ffffff"
    }
}
